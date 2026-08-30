"""Builds the APA 7 Word report for MSCS-533 Assignment 1.

Usage:
    pip install python-docx
    python3 make_report.py

Writes Assignment1_UnitConverter_Report.docx next to this script.
Edit the STUDENT / COURSE constants below before running.
"""

from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.shared import Pt, Inches, RGBColor

# --- fill these in -----------------------------------------------------------
TITLE = "Building a Metric and Imperial Unit Conversion App with Flutter"
STUDENT = "Sandesh Ghimire"
UNIVERSITY = "University of the Cumberlands"
COURSE = "MSCS-533: Mobile Application Development"
INSTRUCTOR = "Dr. [Instructor Name]"
DUE_DATE = "August 30, 2026"
REPO_URL = "https://github.com/<your-username>/mscs533-unit-converter"
# -----------------------------------------------------------------------------

OUTPUT = Path(__file__).with_name("Assignment1_UnitConverter_Report.docx")


def setup_document():
    """APA 7: 1 in margins, Times New Roman 12 pt, double spaced."""
    doc = Document()

    section = doc.sections[0]
    section.top_margin = Inches(1)
    section.bottom_margin = Inches(1)
    section.left_margin = Inches(1)
    section.right_margin = Inches(1)

    normal = doc.styles["Normal"]
    normal.font.name = "Times New Roman"
    normal.font.size = Pt(12)
    normal.paragraph_format.line_spacing = 2.0
    normal.paragraph_format.space_after = Pt(0)

    return doc


def add_page_number_header(doc):
    """APA 7 student papers carry a page number in the top right corner."""
    from docx.oxml.ns import qn
    from docx.oxml import OxmlElement

    header_para = doc.sections[0].header.paragraphs[0]
    header_para.alignment = WD_ALIGN_PARAGRAPH.RIGHT

    run = header_para.add_run()
    for instruction in ("begin", "PAGE", "end"):
        element = OxmlElement("w:fldChar" if instruction != "PAGE" else "w:instrText")
        if instruction == "PAGE":
            element.set(qn("xml:space"), "preserve")
            element.text = " PAGE "
        else:
            element.set(qn("w:fldCharType"), instruction)
        run._r.append(element)

    run.font.name = "Times New Roman"
    run.font.size = Pt(12)


def title_page(doc):
    for _ in range(4):
        doc.add_paragraph()

    heading = doc.add_paragraph()
    heading.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = heading.add_run(TITLE)
    run.bold = True

    doc.add_paragraph()

    for line in (STUDENT, UNIVERSITY, COURSE, INSTRUCTOR, DUE_DATE):
        para = doc.add_paragraph(line)
        para.alignment = WD_ALIGN_PARAGRAPH.CENTER

    doc.add_paragraph().add_run().add_break(WD_BREAK.PAGE)


def heading1(doc, text):
    para = doc.add_paragraph()
    para.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = para.add_run(text)
    run.bold = True
    run.font.name = "Times New Roman"
    run.font.size = Pt(12)
    return para


def heading2(doc, text):
    para = doc.add_paragraph()
    run = para.add_run(text)
    run.bold = True
    run.font.name = "Times New Roman"
    run.font.size = Pt(12)
    return para


def body(doc, text):
    para = doc.add_paragraph(text)
    para.paragraph_format.first_line_indent = Inches(0.5)
    return para


def figure(doc, number, caption, note):
    """A placeholder block where a screenshot should be pasted."""
    label = doc.add_paragraph()
    label.add_run(f"Figure {number}").bold = True

    cap = doc.add_paragraph()
    cap.add_run(caption).italic = True

    placeholder = doc.add_paragraph()
    placeholder.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = placeholder.add_run(f"[ INSERT SCREENSHOT HERE — {note} ]")
    run.italic = True
    run.font.color.rgb = RGBColor(0x88, 0x88, 0x88)

    doc.add_paragraph()


def code_block(doc, lines):
    """Single spaced monospace block for source listings."""
    for line in lines:
        para = doc.add_paragraph()
        para.paragraph_format.line_spacing = 1.0
        para.paragraph_format.left_indent = Inches(0.5)
        para.paragraph_format.space_after = Pt(0)
        run = para.add_run(line if line else " ")
        run.font.name = "Courier New"
        run.font.size = Pt(10)
    doc.add_paragraph()


def reference(doc, text):
    para = doc.add_paragraph(text)
    para.paragraph_format.first_line_indent = Inches(-0.5)
    para.paragraph_format.left_indent = Inches(0.5)


def build():
    doc = setup_document()
    add_page_number_header(doc)
    title_page(doc)

    # ---------------------------------------------------------------- intro
    heading1(doc, TITLE)

    body(
        doc,
        "Converting between metric and imperial measures is one of those small "
        "problems that never quite goes away. Recipes are written in cups, "
        "running apps report kilometres, and shipping labels use pounds. This "
        "assignment asked for a mobile application that closes that gap: the "
        "user picks a measure, chooses the unit they have and the unit they "
        "want, and reads the answer. The application was built with Dart and "
        "the Flutter framework, which compiles a single codebase to native iOS "
        "and Android binaries (Google, 2025a). This report walks through the "
        "development environment, the design decisions behind the app, the "
        "implementation, and the testing that was done.",
    )

    # ------------------------------------------------------- environment
    heading1(doc, "Development Environment")

    body(
        doc,
        "Development was done on macOS, which is the only platform able to "
        "build and sign iOS applications, so the iOS Simulator was used as the "
        "test target. The Flutter SDK (version 3.47.2, stable channel) was "
        "installed through Homebrew and added to the shell PATH, with Visual "
        "Studio Code and the Dart and Flutter extensions as the editor. "
        "GitHub Copilot was enabled as a coding assistant, though every "
        "suggestion was reviewed before being accepted (GitHub, 2025).",
    )

    body(
        doc,
        "The toolchain took two attempts to get right, which is worth "
        "recording. On the first pass flutter doctor rejected the installed "
        "Xcode 14.3, since current Flutter releases require Xcode 15 or higher "
        "for iOS (Google, 2025b). The Simulator itself would still open, which "
        "is misleading: launching the Simulator only proves that the device is "
        "available, not that an application has been installed onto it. Until "
        "Xcode was upgraded, running the project simply produced screenshots "
        "of the iOS home screen. After updating macOS and installing the "
        "current Xcode from the App Store, registering it with xcode-select "
        "and xcodebuild -runFirstLaunch, and installing CocoaPods for iOS "
        "plugin resolution, the toolchain check passed. Running flutter clean "
        "before the first successful build was also necessary, because the "
        "cached artefacts left behind by the older Xcode caused the CocoaPods "
        "step to fail. In the meantime the web target was a useful way to "
        "verify the interface without a working iOS toolchain, which is one of "
        "the practical benefits of Flutter compiling one codebase to several "
        "platforms (Google, 2025a).",
    )

    figure(
        doc,
        1,
        "Output of flutter doctor confirming a working macOS and iOS toolchain.",
        "terminal output of `flutter doctor`",
    )

    # ------------------------------------------------------------ design
    heading1(doc, "Application Design")

    body(
        doc,
        "The interface was deliberately kept to a single screen. A row of "
        "selectable chips across the top chooses the measure family — Length, "
        "Weight, Temperature, or Volume. Below it sits a numeric text field, "
        "then two dropdown menus labelled From and To, and a swap button that "
        "exchanges them. The converted value appears in a coloured card at the "
        "bottom of the screen and updates on every keystroke rather than "
        "waiting for a Convert button, which makes the app feel immediate. "
        "Material 3 theming was used so the colour palette is derived from a "
        "single seed colour and stays consistent across widgets (Google, "
        "2025a).",
    )

    body(
        doc,
        "Keeping the measure families separate matters for correctness as much "
        "as for usability. Kilograms cannot meaningfully be converted into "
        "miles, so the unit lists are scoped to the selected category and the "
        "conversion function rejects any request whose units come from "
        "different families.",
    )

    heading2(doc, "Code Structure")

    body(
        doc,
        "Rather than putting everything into main.dart, the source was split "
        "along responsibility lines, which is the layout Effective Dart "
        "encourages for anything beyond a toy project (Dart, 2025). The models "
        "directory holds the Unit and Category value types. The data directory "
        "holds the unit tables. The services directory holds the conversion "
        "mathematics and imports nothing from Flutter, which means it can be "
        "tested without spinning up a widget tree. The screens and widgets "
        "directories hold the user interface, with the From and To pickers "
        "sharing one reusable dropdown widget instead of being duplicated.",
    )

    # --------------------------------------------------------------- impl
    heading1(doc, "Implementation")

    body(
        doc,
        "Every unit is described by how many base units it contains. Metres is "
        "the base for length, kilograms for weight, and litres for volume, so a "
        "mile carries a factor of 1609.344 and a pound carries 0.45359237. "
        "These are the exact international definitions rather than rounded "
        "approximations, which means a value converted and then converted back "
        "returns to where it started (Thompson & Taylor, 2008). A conversion is "
        "then a two step trip: multiply into the base unit, divide back out.",
    )

    code_block(
        doc,
        [
            "static double convert({",
            "  required double value,",
            "  required Unit from,",
            "  required Unit to,",
            "  required Category category,",
            "}) {",
            "  if (!category.units.contains(from) ||",
            "      !category.units.contains(to)) {",
            "    throw ArgumentError(",
            "        'Both units must belong to ${category.name}.');",
            "  }",
            "",
            "  if (category.isTemperature) {",
            "    return _convertTemperature(value, from, to);",
            "  }",
            "",
            "  final double inBaseUnits = value * from.toBaseFactor;",
            "  return inBaseUnits / to.toBaseFactor;",
            "}",
        ],
    )

    body(
        doc,
        "Temperature is the exception. Celsius, Fahrenheit, and Kelvin do not "
        "share a zero point, so a single multiplication cannot describe the "
        "relationship between them; each conversion needs an offset as well as "
        "a ratio (Bureau International des Poids et Mesures [BIPM], 2019). The "
        "Category type therefore carries an isTemperature flag, and the "
        "converter routes those requests through a private helper that "
        "normalises the input to Celsius before converting it out again.",
    )

    body(
        doc,
        "Two smaller details were worth the effort. The text field uses an "
        "input formatter that accepts only digits, a single decimal point, and "
        "a leading minus sign, so negative temperatures work but stray "
        "characters never reach the parser. Results are formatted so that "
        "trailing zeros are dropped and values that are extremely large or "
        "small fall back to scientific notation instead of collapsing to zero "
        "on screen.",
    )

    figure(
        doc,
        2,
        "The converter running in the iOS Simulator, converting kilometres to "
        "miles.",
        "app screenshot, Length category",
    )

    figure(
        doc,
        3,
        "The Temperature category, showing a Celsius to Fahrenheit conversion.",
        "app screenshot, Temperature category",
    )

    # ------------------------------------------------------------ testing
    heading1(doc, "Testing")

    body(
        doc,
        "Because the conversion logic is free of Flutter dependencies, it was "
        "covered with plain unit tests run through flutter test. The suite "
        "checks a metric to imperial conversion in both length and weight, "
        "checks the two temperature edge cases that are easy to get wrong "
        "(water freezing at 32 degrees Fahrenheit and absolute zero at "
        "-273.15 degrees Celsius), confirms that a cross-category conversion "
        "throws an ArgumentError, and confirms that the formatter trims "
        "trailing zeros. Floating point comparisons use closeTo with a small "
        "tolerance rather than exact equality, since binary floating point "
        "arithmetic rarely lands on an exact decimal. Static analysis was run "
        "with flutter analyze against the flutter_lints rule set plus a few "
        "stricter rules added in analysis_options.yaml.",
    )

    figure(
        doc,
        4,
        "All unit tests passing.",
        "terminal output of `flutter test`",
    )

    # --------------------------------------------------------- conclusion
    heading1(doc, "Conclusion")

    body(
        doc,
        "The finished application meets the requirement: a user can select a "
        "measure and convert between metric and imperial units for length, "
        "weight, temperature, and volume from one screen. The most valuable "
        "part of the exercise was separating the conversion mathematics from "
        "the interface. That separation made the logic testable in isolation, "
        "kept the widget code short enough to read in one pass, and meant that "
        "adding a fourth category was a matter of appending to a data table "
        "rather than touching the user interface at all. The obvious next steps "
        "would be persisting the user's last selection between launches and "
        "adding a live currency category, which would introduce network calls "
        "and asynchronous state.",
    )

    heading2(doc, "Source Code")

    para = doc.add_paragraph(
        "The complete Dart source, the generated iOS and Android manifests, "
        "and the unit tests are available at: "
    )
    para.add_run(REPO_URL)

    doc.add_paragraph().add_run().add_break(WD_BREAK.PAGE)

    # -------------------------------------------------------- references
    heading1(doc, "References")

    reference(
        doc,
        "Bureau International des Poids et Mesures. (2019). The International "
        "System of Units (SI) (9th ed.). https://www.bipm.org/en/publications"
        "/si-brochure",
    )
    reference(
        doc,
        "Dart. (2025). Effective Dart: Style. https://dart.dev/effective-dart"
        "/style",
    )
    reference(
        doc,
        "GitHub. (2025). GitHub Copilot documentation. https://docs.github.com"
        "/en/copilot",
    )
    reference(
        doc,
        "Google. (2025a). Flutter documentation. https://docs.flutter.dev",
    )
    reference(
        doc,
        "Google. (2025b). Start building Flutter iOS apps on macOS. "
        "https://docs.flutter.dev/get-started/install/macos/mobile-ios",
    )
    reference(
        doc,
        "Thompson, A., & Taylor, B. N. (2008). Guide for the use of the "
        "International System of Units (SI) (NIST Special Publication 811). "
        "National Institute of Standards and Technology. "
        "https://doi.org/10.6028/NIST.SP.811e2008",
    )
    reference(
        doc,
        "Windmill, E. (2020). Flutter in action. Manning Publications.",
    )

    doc.save(OUTPUT)
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    build()
