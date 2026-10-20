"""
Excel Reporter Module for Rootio Automated QA Test Suites.
Formats and writes test execution results to styled, professional .xlsx artifacts.
"""

from datetime import datetime
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter


def generate_excel_report(test_cases, suite_name, output_file_path):
    """
    Generate a formatted Excel (.xlsx) artifact containing all test cases.

    Parameters:
    - test_cases: List of dictionaries with keys:
        'id', 'scenario', 'steps', 'data', 'expected', 'actual', 'status', 'priority'
    - suite_name: Name of the test suite (e.g. 'Load Testing')
    - output_file_path: Target path to write the .xlsx file
    """
    wb = Workbook()

    # Sheet 1: Test Cases Execution Details
    ws_cases = wb.active
    ws_cases.title = "Test Cases"

    # Color Palette - Professional Enterprise Navy / Emerald
    HEADER_FILL = PatternFill(start_color="1B365D", end_color="1B365D", fill_type="solid")
    HEADER_FONT = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
    TITLE_FONT = Font(name="Calibri", size=14, bold=True, color="1B365D")
    REGULAR_FONT = Font(name="Calibri", size=10)
    BOLD_FONT = Font(name="Calibri", size=10, bold=True)

    PASS_FILL = PatternFill(start_color="D4EDDA", end_color="D4EDDA", fill_type="solid")
    PASS_FONT = Font(name="Calibri", size=10, bold=True, color="155724")
    FAIL_FILL = PatternFill(start_color="F8D7DA", end_color="F8D7DA", fill_type="solid")
    FAIL_FONT = Font(name="Calibri", size=10, bold=True, color="721C24")
    WARNING_FILL = PatternFill(start_color="FFF3CD", end_color="FFF3CD", fill_type="solid")
    WARNING_FONT = Font(name="Calibri", size=10, bold=True, color="856404")

    THIN_BORDER = Border(
        left=Side(style='thin', color='D9D9D9'),
        right=Side(style='thin', color='D9D9D9'),
        top=Side(style='thin', color='D9D9D9'),
        bottom=Side(style='thin', color='D9D9D9')
    )

    # Title Block
    ws_cases.merge_cells("A1:H1")
    title_cell = ws_cases["A1"]
    title_cell.value = f"Rootio — {suite_name} Execution Report"
    title_cell.font = TITLE_FONT
    title_cell.alignment = Alignment(horizontal="left", vertical="center")

    ws_cases.merge_cells("A2:H2")
    meta_cell = ws_cases["A2"]
    meta_cell.value = f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} | Target: Rootio v1.0.0+1 | Total Cases: {len(test_cases)}"
    meta_cell.font = Font(name="Calibri", size=9, italic=True, color="555555")

    # Table Headers
    headers = [
        "Test Case ID",
        "Test Scenario",
        "Test Steps",
        "Test Data",
        "Expected Result",
        "Actual Result",
        "Status",
        "Priority"
    ]

    header_row = 4
    for col_idx, header in enumerate(headers, 1):
        cell = ws_cases.cell(row=header_row, column=col_idx, value=header)
        cell.font = HEADER_FONT
        cell.fill = HEADER_FILL
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        cell.border = THIN_BORDER

    # Populate Test Cases
    current_row = header_row + 1
    total_passed = 0
    total_failed = 0
    total_warning = 0

    for tc in test_cases:
        c_id = ws_cases.cell(row=current_row, column=1, value=tc["id"])
        c_sc = ws_cases.cell(row=current_row, column=2, value=tc["scenario"])
        c_st = ws_cases.cell(row=current_row, column=3, value=tc["steps"])
        c_dt = ws_cases.cell(row=current_row, column=4, value=tc["data"])
        c_ex = ws_cases.cell(row=current_row, column=5, value=tc["expected"])
        c_ac = ws_cases.cell(row=current_row, column=6, value=tc["actual"])
        c_stat = ws_cases.cell(row=current_row, column=7, value=tc["status"])
        c_pr = ws_cases.cell(row=current_row, column=8, value=tc["priority"])

        # Format alignments and fonts
        c_id.font = BOLD_FONT
        c_id.alignment = Alignment(horizontal="center", vertical="top")

        for c in [c_sc, c_st, c_dt, c_ex, c_ac]:
            c.font = REGULAR_FONT
            c.alignment = Alignment(horizontal="left", vertical="top", wrap_text=True)

        c_stat.alignment = Alignment(horizontal="center", vertical="top")
        c_pr.alignment = Alignment(horizontal="center", vertical="top")
        c_pr.font = BOLD_FONT

        # Status badge styling
        status_val = str(tc["status"]).upper()
        if "PASS" in status_val:
            c_stat.fill = PASS_FILL
            c_stat.font = PASS_FONT
            total_passed += 1
        elif "FAIL" in status_val:
            c_stat.fill = FAIL_FILL
            c_stat.font = FAIL_FONT
            total_failed += 1
        else:
            c_stat.fill = WARNING_FILL
            c_stat.font = WARNING_FONT
            total_warning += 1

        for c in [c_id, c_sc, c_st, c_dt, c_ex, c_ac, c_stat, c_pr]:
            c.border = THIN_BORDER

        current_row += 1

    # Auto-adjust column widths
    col_widths = {
        "A": 16, # Test Case ID
        "B": 36, # Scenario
        "C": 48, # Steps
        "D": 38, # Data
        "E": 44, # Expected
        "F": 44, # Actual
        "G": 14, # Status
        "H": 12  # Priority
    }
    for col_letter, width in col_widths.items():
        ws_cases.column_dimensions[col_letter].width = width

    # Sheet 2: Executive Summary & Metrics Dashboard
    ws_sum = wb.create_sheet(title="Executive Summary")
    ws_sum.column_dimensions["A"].width = 24
    ws_sum.column_dimensions["B"].width = 24
    ws_sum.column_dimensions["C"].width = 30

    ws_sum["A1"] = f"Rootio QA Executive Summary — {suite_name}"
    ws_sum["A1"].font = TITLE_FONT
    ws_sum.merge_cells("A1:C1")

    ws_sum["A3"] = "Metric"
    ws_sum["B3"] = "Value"
    ws_sum["C3"] = "Percentage"
    for col in ["A", "B", "C"]:
        ws_sum[f"{col}3"].font = HEADER_FONT
        ws_sum[f"{col}3"].fill = HEADER_FILL
        ws_sum[f"{col}3"].alignment = Alignment(horizontal="center", vertical="center")

    total_cases = len(test_cases)
    metrics = [
        ("Total Test Cases", total_cases, "100.0%"),
        ("Passed", total_passed, f"{(total_passed / total_cases * 100):.1f}%" if total_cases else "0%"),
        ("Failed", total_failed, f"{(total_failed / total_cases * 100):.1f}%" if total_cases else "0%"),
        ("Warning / Flagged", total_warning, f"{(total_warning / total_cases * 100):.1f}%" if total_cases else "0%"),
    ]

    for idx, (m_label, m_val, m_pct) in enumerate(metrics, 4):
        ws_sum[f"A{idx}"] = m_label
        ws_sum[f"B{idx}"] = m_val
        ws_sum[f"C{idx}"] = m_pct
        for col in ["A", "B", "C"]:
            ws_sum[f"{col}{idx}"].border = THIN_BORDER
            ws_sum[f"{col}{idx}"].font = BOLD_FONT if idx == 4 else REGULAR_FONT
            ws_sum[f"{col}{idx}"].alignment = Alignment(horizontal="center" if col != "A" else "left")

    wb.save(output_file_path)
    print(f"[REPORTER] Successfully generated Excel artifact: {output_file_path} ({len(test_cases)} test cases)")
