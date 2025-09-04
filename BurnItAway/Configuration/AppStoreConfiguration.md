# App Store Connect Configuration

## Subscription Setup

To enable the subscription functionality, you need to configure the following in App Store Connect:

### 1. Create Subscription Group
- **Group Name**: "BurnItAway Premium"
- **Reference Name**: "premium_subscriptions"

### 2. Create Monthly Subscription Product
- **Product ID**: `com.burnitaway.premium.monthly`
- **Display Name**: "Premium Monthly"
- **Description**: "Unlimited worry burning with premium features"
- **Subscription Duration**: 1 Month
- **Price**: Set your desired price (e.g., $2.99/month)

### 3. Subscription Features
- **Free Trial**: 7 days (optional)
- **Introductory Price**: Set if desired
- **Auto-Renewable**: Yes

### 4. Localization
Add localized descriptions for different markets:
- **English**: "Unlimited worry burning with premium features"
- **Spanish**: "Quema ilimitada de preocupaciones con funciones premium"
- **French**: "Brûlage illimité d'inquiétudes avec des fonctionnalités premium"

### 5. App Store Review Information
- **Review Notes**: "This app uses in-app purchases for premium subscription features"
- **Demo Account**: Provide test account credentials if required

## Testing

### Sandbox Testing
1. Create sandbox test accounts in App Store Connect
2. Sign out of App Store on device
3. Sign in with sandbox account
4. Test subscription purchase flow

### Test Scenarios
- [ ] Purchase monthly subscription
- [ ] Free trial activation (if enabled)
- [ ] Subscription renewal
- [ ] Restore purchases
- [ ] Subscription cancellation
- [ ] Refund handling

## Revenue Optimization

### Pricing Strategy
- **Monthly**: $2.99/month
- **Annual**: $19.99/year (33% savings)
- **Free Trial**: 7 days to reduce friction

### Conversion Optimization
- Show upgrade prompts when users hit daily limits
- Highlight premium features in paywall
- Use compelling copy about unlimited access
- Offer free trial to reduce purchase anxiety

## Analytics

Track these key metrics:
- **Conversion Rate**: % of users who subscribe
- **Trial-to-Paid**: % of trial users who convert
- **Churn Rate**: % of subscribers who cancel
- **LTV**: Lifetime value of subscribers
- **ARPU**: Average revenue per user

## Legal Requirements

### Terms of Service
Include subscription terms:
- Auto-renewal policy
- Cancellation instructions
- Refund policy
- Price changes notice

### Privacy Policy
Disclose:
- Subscription data collection
- Payment processing
- User data usage for premium features

## Support

### Customer Service
- Provide clear cancellation instructions
- Handle refund requests promptly
- Monitor subscription-related support tickets

### Documentation
- Create FAQ for subscription questions
- Provide troubleshooting guides
- Document common issues and solutions
