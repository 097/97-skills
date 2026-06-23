#!/usr/bin/env python3
"""给 PDF 底部居中叠加页码「X / N」。
用法: add_page_numbers.py <pdf_path>   # 原地改写
依赖: pypdf、reportlab。缺库时调用方应跳过本步（PDF 仍可用）。
页码落在底部约 7mm 处（A4 下边距 18mm 内的留白），灰色 8pt，不压正文。
"""
import sys
from io import BytesIO

from pypdf import PdfReader, PdfWriter
from reportlab.pdfgen import canvas


def main() -> None:
    path = sys.argv[1]
    reader = PdfReader(path)
    total = len(reader.pages)
    writer = PdfWriter()
    for idx, page in enumerate(reader.pages, start=1):
        w = float(page.mediabox.width)
        h = float(page.mediabox.height)
        buf = BytesIO()
        c = canvas.Canvas(buf, pagesize=(w, h))
        c.setFont("Helvetica", 8)
        c.setFillGray(0.5)
        c.drawCentredString(w / 2.0, 20, f"{idx} / {total}")  # 20pt ≈ 7mm
        c.save()
        buf.seek(0)
        page.merge_page(PdfReader(buf).pages[0])
        writer.add_page(page)
    with open(path, "wb") as f:
        writer.write(f)


if __name__ == "__main__":
    main()
