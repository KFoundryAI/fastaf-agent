# Synthetic MPS Dataset (Toner Supply & Usage)

**Date range:** 2024-09-01 to 2025-08-31
**Clients:** Kroger (retail), Lex & Co (law), Taxify LLP (tax)
**Oversupply event day:** 2025-03-18 (many manual_bulk orders for Ricoh @ Kroger)
**Notes:** Includes low-toner alerts, automated orders, delayed/unused shipments, seasonal spikes.

## Files
- `devices.csv` — device catalog
- `meter_readings.csv` — daily pages per device and cumulative pages
- `orders.csv` — toner orders/shipments (reason=`low_alert` or `manual_bulk`), `oversupply_flag` marks anomaly
- `toner_events.csv` — actual toner replacement events; missing event after an order suggests "shipped but not installed"
- `alerts.csv` — low toner alerts generated at ~20% remaining

## devices.csv
- device_id, client, client_type, location, model, toner_model, toner_yield, is_ricoh, integrated_fastaf, base_daily_pages

## meter_readings.csv
- device_id, date, pages_printed (per day), cum_pages (cumulative)

## orders.csv
- order_id, device_id, client, toner_model, order_date, quantity, reason (`low_alert` = auto JIT, `manual_bulk` = oversupply day), oversupply_flag (bool)

## toner_events.csv
- device_id, event_date, event_type (TONER_REPLACED), order_id_linked, notes

## alerts.csv
- device_id, alert_date, level_percent, alert_type (TONER_LOW)
