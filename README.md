> Incentivizing sustainable water collection through blockchain technology 🌍

## 🚀 Overview

The Rainwater Harvest Credit System is a decentralized solution that rewards communities and individuals for collecting and storing rainwater. Users earn tokenized credits that can be redeemed in a marketplace for farm supplies and subsidies.

## ✨ Key Features

- 🌧️ **IoT Integration**: Connect rainwater meters to track water collection automatically
- 🪙 **Token Rewards**: Earn credits for meeting water storage targets
- 🛒 **Marketplace**: Redeem credits for farm supplies and subsidies
- 📊 **Real-time Monitoring**: Track water levels and collection progress
- 🔒 **Secure Trading**: Safe credit transfers between users

## 🛠️ Technical Stack

- **Blockchain**: Stacks (Clarity Smart Contracts)
- **Framework**: Clarinet
- **Language**: Clarity v3

## 📋 Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed
- Node.js (for development)
- Stacks wallet for testing

## 🏃‍♂️ Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd Rainwater-Harvest-Credit-System
clarinet check
```

### 2. Deploy Contract
```bash
clarinet deploy --testnet
```

### 3. Test Functions
```bash
clarinet console
```

## 📖 Usage Guide

### 🏠 Register a Rainwater Meter
```clarity
(contract-call? .Rainwater-Harvest-Credit-System register-meter "Farm Location A" u1000)
```

### 📊 Record Water Reading
```clarity
(contract-call? .Rainwater-Harvest-Credit-System record-water-reading u1 u1200 u1)
```

### 🪙 Check Your Credits
```clarity
(contract-call? .Rainwater-Harvest-Credit-System get-user-credits 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### 🛒 Create Marketplace Product
```clarity
(contract-call? .Rainwater-Harvest-Credit-System create-marketplace-product "Fertilizer Pack" "Organic fertilizer for crops" u100 "farm-supplies")
```

### 💳 Purchase Product
```clarity
(contract-call? .Rainwater-Harvest-Credit-System purchase-product u1 u1)
```

### 💸 Transfer Credits
```clarity
(contract-call? .Rainwater-Harvest-Credit-System transfer-credits 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG u50)
```

## 🔧 Core Functions

### Owner Functions
- `authorize-operator` - Add IoT operators
- `revoke-operator` - Remove operators
- `set-reward-rate` - Adjust credit rewards

### User Functions
- `register-meter` - Register new rainwater collection meter
- `record-water-reading` - Submit water collection data
- `create-marketplace-product` - List items for sale
- `purchase-product` - Buy items with credits
- `transfer-credits` - Send credits to other users

### View Functions
- `get-user-credits` - Check credit balance
- `get-meter-info` - View meter details
- `get-product-info` - Check marketplace listings

## 🏗️ Architecture

### Data Storage
- **User Credits**: Track individual credit balances
- **Rainwater Meters**: Store meter configurations and readings
- **Marketplace**: Product listings and purchase history
- **Operator Management**: Authorized IoT device operators

### Credit System
- Credits are awarded when water storage targets are met
- Reward rate is configurable by contract owner
- Credits can be transferred between users
- Marketplace enables credit redemption

## 🧪 Testing

```bash
# Run all tests
clarinet test

# Check contract syntax
clarinet check

# Analyze contract
clarinet analyze
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🌟 Future Enhancements

- 📱 Mobile app integration
- 🌐 Web dashboard for monitoring
- 🤖 Automated IoT device integration
- 📈 Analytics and reporting features
- 🌍 Multi-region support

---

**Built with 💚 for sustainable water management**
