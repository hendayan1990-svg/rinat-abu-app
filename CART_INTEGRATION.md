# 0.5.0 Preview

Android now uses WooCommerce's public Store Cart API with nonce validation and the same cookie session as an in-app WebView showing the official checkout. The app never supplies a payable total or submits an order. Quantities, prices, stock and coupons are validated by the merchant. Variable products open their official product page for selection. API GET requests use a timestamp to prevent stale cached empty-cart responses.

Gift cards issued by the separate app manager are NOT integrated into WooCommerce. The cart offers a card-number field and explicit copy/manual-redemption explanation; it does not claim a discount or decrement card balances. Existing official checkout methods remain controlled by the site. No website files, settings or payment configuration were changed.

Hebrew, English, Arabic and Russian UI with persisted preference. Product names remain the official source language. Original brand logo, rounded burgundy/gold gift card design with live amount selection; no invented issued card number or expiry in the selection preview.

Verification: Android APK compiled and signer verification passed. Isolated guest-session test added a product via Store API, verified it appeared in the official cart HTML, verified subsequent API retrieval and removed test items. No checkout/payment was submitted. Cache-busting was necessary for fresh GET results. No physical Android device test performed. Browser preview has localized design; native cart is Android-only in this release. Manager backend remains owner-private pending approval.
