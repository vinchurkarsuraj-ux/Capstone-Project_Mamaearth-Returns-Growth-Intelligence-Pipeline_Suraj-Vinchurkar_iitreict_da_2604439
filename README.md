# Capstone-Project_Mamaearth-Returns-Growth-Intelligence-Pipeline_Suraj-Vinchurkar_iitreict_da_2604439
Final Submission: Capstone Project — Mamaearth Returns &amp; Growth Intelligence Pipeline under Data Analytics with AI &amp; Gen AI program

#Project Overview

    Mamaearth Returns & Growth Intelligence Pipeline is an end-to-end data engineering and analytics capstone project designed to evaluate product returns, customer behavior, and sales growth drivers. Built for full reproducibility, the repository integrates a relational database workflow using SQL schema scripts and analytical reports, followed by Python-based data cleaning, exploratory data analysis, and visualization scripts. It features an automated narrative generation engine powered by the Gemini API—supported by a seamless offline template fallback. This pipeline translates raw e-commerce metrics into structured findings (narrator/findings.json) and actionable business intelligence for strategic growth optimization.

    Capstone-Project_Mamaearth-Returns-Growth-Intelligence-Pipeline/
    
├── README.md                          # Comprehensive pipeline documentation
├── sql/                               # [Step 1] Database & SQL Analysis
│   ├── schema.sql                     # Database table structures and constraints
│   ├── seed_data.sql                  # Seed datasets for initialization
│   └── reports.sql                    # SQL aggregation queries & report scripts
│
├── analysis/                          # [Step 2] Data Processing & Visualization
│   ├── clean_and_eda.py               # Data cleaning, preprocessing & EDA
│   └── visualize.py                   # Chart generation & statistical plots
│
└── narrator/                          # [Step 3] AI Findings & Narrative Pipeline
    ├── findings.json                  # Exported metrics from Task 5 (Part 2)
    └── generate_narrative.py          # AI narrative engine (Gemini API / Offline Mode)
