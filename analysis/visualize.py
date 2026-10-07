import pandas as pd
import matplotlib.pyplot as plt
import os

# Ensure visualizations directory exists
os.makedirs("visualizations", exist_ok=True)

# Re-run required cleaning steps to generate chart data
customers = pd.read_csv("data/customers.csv")
products = pd.read_csv("data/products.csv")
orders = pd.read_csv("data/orders.csv")

orders['payment_method'] = orders['payment_method'].str.strip().str.upper()
natural_key = ['customer_id', 'product_id', 'order_date', 'quantity', 'discount_pct', 'payment_method', 'rating', 'returned']
orders_clean = orders.drop_duplicates(subset=natural_key, keep='first').copy()
orders_clean['discount_pct'] = orders_clean['discount_pct'].fillna(0)
orders_clean['rating'] = orders_clean['rating'].fillna(orders_clean['rating'].median())

merged = orders_clean.merge(products, on='product_id', how='left') \
                     .merge(customers, on='customer_id', how='left')
merged['order_value'] = merged['quantity'] * merged['price'] * (1 - merged['discount_pct'] / 100)

# Outlier filter for time series
Q1 = merged['quantity'].quantile(0.25)
Q3 = merged['quantity'].quantile(0.75)
IQR = Q3 - Q1
merged['is_outlier'] = (merged['quantity'] < (Q1 - 1.5 * IQR)) | (merged['quantity'] > (Q3 + 1.5 * IQR))

# 1. return_rate_by_payment.png
return_by_pm = merged.groupby('payment_method')['returned'].mean().mul(100).sort_values(ascending=False)

plt.figure(figsize=(8, 5))
bars = plt.bar(return_by_pm.index, return_by_pm.values, color=['#d9534f', '#f0ad4e', '#5bc0de'])
plt.title("COD Returns at 44.4% — 3x Card", fontsize=14, fontweight='bold')
plt.xlabel("Payment Method", fontsize=12)
plt.ylabel("Return Rate (%)", fontsize=12)
plt.ylim(0, 55)

for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2.0, yval + 1, f"{yval:.1f}%", ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig("visualizations/return_rate_by_payment.png", dpi=300)
plt.close()

# 2. monthly_revenue_trend.png
merged['order_date'] = pd.to_datetime(merged['order_date'])
merged['year_month'] = merged['order_date'].dt.to_period('M').astype(str)
monthly_rev = merged[~merged['is_outlier']].groupby('year_month')['order_value'].sum()

plt.figure(figsize=(9, 5))
plt.plot(monthly_rev.index, monthly_rev.values, marker='o', color='#2b5c8f', linewidth=2.5, markersize=6)
plt.title("Outlier-Corrected Monthly Revenue Trend (Peak: March 2026)", fontsize=14, fontweight='bold')
plt.xlabel("Month", fontsize=12)
plt.ylabel("Revenue (INR)", fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)

for x, y in zip(monthly_rev.index, monthly_rev.values):
    plt.text(x, y + 500, f"Rs. {y:,.0f}", ha='center', va='bottom', fontsize=9, fontweight='bold')

plt.tight_layout()
plt.savefig("visualizations/monthly_revenue_trend.png", dpi=300)
plt.close()

print("Visualizations successfully generated and saved under visualizations/")
