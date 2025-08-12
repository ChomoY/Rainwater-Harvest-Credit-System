;; Rainwater Harvest Credit System

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INSUFFICIENT_CREDITS (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))
(define-constant ERR_ALREADY_EXISTS (err u104))
(define-constant ERR_UNAUTHORIZED (err u105))
(define-constant ERR_INVALID_METER (err u106))
(define-constant ERR_INVALID_TARGET (err u107))

;; Data Variables
(define-data-var total-credits uint u0)
(define-data-var next-meter-id uint u1)
(define-data-var next-product-id uint u1)
(define-data-var reward-rate uint u10)

;; Data Maps
(define-map user-credits principal uint)
(define-map authorized-operators principal bool)

(define-map rainwater-meters
  uint
  {
    owner: principal,
    location: (string-ascii 100),
    current-storage: uint,
    target-storage: uint,
    is-active: bool,
    last-reading: uint
  }
)

(define-map meter-readings
  {meter-id: uint, reading-id: uint}
  {
    timestamp: uint,
    water-amount: uint,
    operator: principal
  }
)

(define-map marketplace-products
  uint
  {
    seller: principal,
    name: (string-ascii 50),
    description: (string-ascii 200),
    price: uint,
    category: (string-ascii 30),
    available: bool
  }
)

(define-map user-purchases
  {user: principal, purchase-id: uint}
  {
    product-id: uint,
    amount-paid: uint,
    timestamp: uint
  }
)

(define-map meter-rewards
  uint
  {
    total-earned: uint,
    last-reward-block: uint
  }
)

;; Public Functions

(define-public (register-meter (location (string-ascii 100)) (target-storage uint))
  (let ((meter-id (var-get next-meter-id)))
    (asserts! (> target-storage u0) ERR_INVALID_TARGET)
    (map-set rainwater-meters
      meter-id
      {
        owner: tx-sender,
        location: location,
        current-storage: u0,
        target-storage: target-storage,
        is-active: true,
        last-reading: u0
      }
    )
    (map-set meter-rewards
      meter-id
      {
        total-earned: u0,
        last-reward-block: stacks-block-height
      }
    )
    (var-set next-meter-id (+ meter-id u1))
    (ok meter-id)
  )
)

(define-public (authorize-operator (operator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (map-set authorized-operators operator true)
    (ok true)
  )
)

(define-public (revoke-operator (operator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (map-delete authorized-operators operator)
    (ok true)
  )
)

(define-public (record-water-reading (meter-id uint) (water-amount uint) (reading-id uint))
  (let (
    (meter (unwrap! (map-get? rainwater-meters meter-id) ERR_NOT_FOUND))
    (is-operator (default-to false (map-get? authorized-operators tx-sender)))
    (is-owner (is-eq tx-sender (get owner meter)))
  )
    (asserts! (or is-operator is-owner) ERR_UNAUTHORIZED)
    (asserts! (get is-active meter) ERR_INVALID_METER)
    (asserts! (> water-amount u0) ERR_INVALID_AMOUNT)
    
    (map-set rainwater-meters
      meter-id
      (merge meter {
        current-storage: water-amount,
        last-reading: stacks-block-height
      })
    )
    
    (map-set meter-readings
      {meter-id: meter-id, reading-id: reading-id}
      {
        timestamp: stacks-block-height,
        water-amount: water-amount,
        operator: tx-sender
      }
    )
    
    (if (>= water-amount (get target-storage meter))
      (award-credits meter-id)
      (ok u0)
    )
  )
)

(define-public (award-credits (meter-id uint))
  (let (
    (meter (unwrap! (map-get? rainwater-meters meter-id) ERR_NOT_FOUND))
    (rewards (unwrap! (map-get? meter-rewards meter-id) ERR_NOT_FOUND))
    (blocks-passed (- stacks-block-height (get last-reward-block rewards)))
    (credits-to-award (* blocks-passed (var-get reward-rate)))
    (owner (get owner meter))
    (current-credits (default-to u0 (map-get? user-credits owner)))
  )
    (asserts! (>= (get current-storage meter) (get target-storage meter)) ERR_INVALID_AMOUNT)
    
    (map-set user-credits owner (+ current-credits credits-to-award))
    (map-set meter-rewards
      meter-id
      (merge rewards {
        total-earned: (+ (get total-earned rewards) credits-to-award),
        last-reward-block: stacks-block-height
      })
    )
    (var-set total-credits (+ (var-get total-credits) credits-to-award))
    (ok credits-to-award)
  )
)

(define-public (create-marketplace-product 
  (name (string-ascii 50)) 
  (description (string-ascii 200)) 
  (price uint)
  (category (string-ascii 30))
)
  (let ((product-id (var-get next-product-id)))
    (asserts! (> price u0) ERR_INVALID_AMOUNT)
    (map-set marketplace-products
      product-id
      {
        seller: tx-sender,
        name: name,
        description: description,
        price: price,
        category: category,
        available: true
      }
    )
    (var-set next-product-id (+ product-id u1))
    (ok product-id)
  )
)

(define-public (purchase-product (product-id uint) (purchase-id uint))
  (let (
    (product (unwrap! (map-get? marketplace-products product-id) ERR_NOT_FOUND))
    (buyer-credits (default-to u0 (map-get? user-credits tx-sender)))
    (price (get price product))
  )
    (asserts! (get available product) ERR_NOT_FOUND)
    (asserts! (>= buyer-credits price) ERR_INSUFFICIENT_CREDITS)
    
    (map-set user-credits tx-sender (- buyer-credits price))
    (map-set user-credits (get seller product) 
      (+ (default-to u0 (map-get? user-credits (get seller product))) price))
    
    (map-set user-purchases
      {user: tx-sender, purchase-id: purchase-id}
      {
        product-id: product-id,
        amount-paid: price,
        timestamp: stacks-block-height
      }
    )
    (ok true)
  )
)

(define-public (toggle-product-availability (product-id uint))
  (let ((product (unwrap! (map-get? marketplace-products product-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get seller product)) ERR_UNAUTHORIZED)
    (map-set marketplace-products
      product-id
      (merge product {available: (not (get available product))})
    )
    (ok true)
  )
)

(define-public (transfer-credits (recipient principal) (amount uint))
  (let ((sender-credits (default-to u0 (map-get? user-credits tx-sender))))
    (asserts! (>= sender-credits amount) ERR_INSUFFICIENT_CREDITS)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    
    (map-set user-credits tx-sender (- sender-credits amount))
    (map-set user-credits recipient 
      (+ (default-to u0 (map-get? user-credits recipient)) amount))
    (ok true)
  )
)

(define-public (set-reward-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set reward-rate new-rate)
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-user-credits (user principal))
  (default-to u0 (map-get? user-credits user))
)

(define-read-only (get-meter-info (meter-id uint))
  (map-get? rainwater-meters meter-id)
)

(define-read-only (get-meter-reading (meter-id uint) (reading-id uint))
  (map-get? meter-readings {meter-id: meter-id, reading-id: reading-id})
)

(define-read-only (get-product-info (product-id uint))
  (map-get? marketplace-products product-id)
)

(define-read-only (get-user-purchase (user principal) (purchase-id uint))
  (map-get? user-purchases {user: user, purchase-id: purchase-id})
)

(define-read-only (get-meter-rewards (meter-id uint))
  (map-get? meter-rewards meter-id)
)

(define-read-only (get-total-credits)
  (var-get total-credits)
)

(define-read-only (get-reward-rate)
  (var-get reward-rate)
)

(define-read-only (is-authorized-operator (operator principal))
  (default-to false (map-get? authorized-operators operator))
)

(define-read-only (get-contract-owner)
  CONTRACT_OWNER
)
