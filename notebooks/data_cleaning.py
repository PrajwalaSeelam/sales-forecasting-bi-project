import pandas as pd
import numpy as np
import os

def run_etl_pipeline():
    raw_path = os.path.join('data', 'raw_sales.csv')
    clean_path = os.path.join('data', 'cleaned_sales_data.csv')
    
    if not os.path.exists(raw_path):
        print(f"Error: Missing target file at {raw_path}")
        return
        
    # 1. Ingest raw data
    df = pd.read_csv(raw_path)
    print(f"Pipeline Ingestion Status: Success ({len(df)} records loaded)")
    
    # 2. Database readiness: lowercase columns and remove spaces
    df.columns = df.columns.str.replace(' ', '_').str.lower().str.replace('-', '_')
    
    # 3. Enforce strong datetimes
    df['order_date'] = pd.to_datetime(df['order_date'])
    df['ship_date'] = pd.to_datetime(df['ship_date'])
    
    # 4. Handle structural anomalies & null values
    df['postal_code'] = df['postal_code'].fillna(0).astype(int)
    df.dropna(subset=['order_date', 'sales', 'profit'], inplace=True)
    
    # 5. Feature Engineering: Derive granular analytical columns
    df['year'] = df['order_date'].dt.year
    df['month'] = df['order_date'].dt.month
    df['year_month'] = df['order_date'].dt.to_period('M').astype(str)
    
    # 6. Structured Export
    df.to_csv(clean_path, index=False)
    print(f"Pipeline Export Status: Success -> Clean file saved at: {clean_path}")

if __name__ == "__main__":
    run_etl_pipeline()