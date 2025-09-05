
Developer Guide: Synthetic MPS Dataset for Supply Agent Prototype

Overview

We’ve built a synthetic but realistic dataset to simulate Managed Print Services (MPS) data for prototyping the revenue-capture agent. It includes:
	•	Devices catalog (color + mono, yields, Ricoh vs non-Ricoh, FastAF integration flags)
	•	Meter readings (daily pages, mono vs color breakdown, seasonal and weekly patterns)
	•	Orders/shipments (auto “low_alert” vs manual “manual_bulk” oversupply, with shipment bundling and SLA dates)
	•	Toner replacement events (linking back to orders when installs occur)
	•	Alerts (low-toner triggers)
	•	Shipments (multi-SKU bundles with SLA performance)
	•	Anomalies & KPIs precomputed for testing agent reasoning
	•	Agent fixtures (ready-to-consume JSONL “morning check” recommendations)

File Locations

CSVs
	•	devices.csv – one row per device per toner channel
	•	meter_readings.csv – daily print usage per device
	•	orders.csv – one row per cartridge ordered
	•	toner_events.csv – actual installs
	•	alerts.csv – toner low alerts
	•	shipments.csv – bundled shipments with SLA fields
	•	anomaly_*.csv – precomputed anomaly slices
	•	kpi/*.csv|.parquet – KPIs and BI-friendly summaries
	•	fixtures/morning_check_2025-03-19.jsonl – per-device recs for the spike day

SQLite
	•	mps_synthetic_v2.sqlite
Includes all base tables + KPI tables + convenience views (vw_daily_orders_summary, vw_install_lag, vw_shipments_sla_perf, etc.).

Data Concepts
	•	Orders: reason=low_alert (normal JIT) or reason=manual_bulk (oversupply day).
	•	Oversupply event: March 18, 2025 — ~1,600 extra Ricoh Kroger orders.
	•	Install lag: Compare orders to toner_events. If no install within 14 days, treat as “unused shipment.”
	•	SLA: Orders are bundled into shipments with ship_date, eta_date, and delivered_date. On-time % is precomputed.
	•	KPIs: Rolling 30/60/90-day averages, unused shipment rate, SLA on-time %, lag distributions.

Using the Data in the Agent

1. Anomaly Detection
	•	Double 90d average: Query vw_daily_orders_summary where spike_flag=1.
	•	Orders without install >14d: vw_install_lag with late_gt14=1.
	•	Excess installs vs expected pages: anomaly_devices_excess_toner_vs_pages (currently empty; threshold configurable).

2. Decision Support

Use the fixtures JSONL for ready-made examples:

{
  "date": "2025-03-19",
  "device_id": "KROGER-1023",
  "client": "Kroger",
  "issues": ["oversupply_spike","multiple_uninstalled_orders"],
  "recommendation": "hold",
  "severity": "red",
  "rationale": "2 manual_bulk orders on spike day; no installs yet.",
  "last7d_pages": 4210
}

Your agent should mimic this pattern when generating daily “morning check” output:
	•	red = block/hold shipment
	•	yellow = ship now or check with site
	•	green = monitor

3. Dashboards / BI
	•	Plot daily order counts vs rolling average (from vw_daily_orders_summary).
	•	Show install lag histograms (from vw_install_lag).
	•	SLA compliance charts (from vw_shipments_sla_perf and vw_kpi_sla_on_time_rate).
	•	Client KPIs (from vw_kpi_orders_trailing_avgs).

4. Testing
	•	Spike detection: Make sure agent flags the March 18 spike.
	•	Unused shipments: Verify that orders with no install >14d are surfaced.
	•	Seasonality handling: Tax & Law spikes (Feb–Apr and EoQ months) should not be flagged as anomalies.
	•	UI integration: Red/yellow/green with rationale visible to analysts.

Next Steps for Devs
	1.	Load mps_synthetic_v2.sqlite into your local dev environment.
	2.	Prototype agent logic against the views (vw_*).
	3.	Use fixtures/morning_check_2025-03-19.jsonl to unit-test recommendation rendering.
	4.	Extend fixtures generation for additional dates to simulate week-over-week monitoring.
	5.	Wire up a simple dashboard (React + FastAPI) using the CSV/Parquet files to visualize anomalies and agent decisions.

⸻

Do you want me to also draft code stubs (e.g., Python classes for Device, Order, and Shipment + functions to query anomalies from SQLite) so your devs can plug straight into the agent workflow?