import os
import re

lib_dir = r"d:\ROICONSI-main\roi_app\lib"

# We want to patch all files in quizeasy, quizhard, and hindi/quizeasyhindi, etc.
target_dirs = [
    os.path.join(lib_dir, 'quizeasy'),
    os.path.join(lib_dir, 'quizhard'),
    os.path.join(lib_dir, 'screens', 'hindi', 'quizeasyhindi'),
    os.path.join(lib_dir, 'screens', 'hindi', 'quizhardhindi'),
]

import_statement = "import 'package:login_signup/screens/homepage_screen.dart';\n"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # 1. Limit questions to 10
    content = re.sub(
        r'questions:\s*snapshot\.data!\)',
        r'questions: snapshot.data!.take(10).toList())',
        content
    )

    # 2. Add quiz history marking to _showFinalScore
    # We look for: 'totalQuizzesCompleted': FieldValue.increment(1),
    # And we append the quizHistory field
    history_str = "      'quizHistory': FieldValue.arrayUnion([{'chapter': 'Quiz', 'score': _score, 'date': DateTime.now().toIso8601String()}]),\n"
    if 'quizHistory' not in content:
        content = re.sub(
            r"('totalQuizzesCompleted':\s*FieldValue\.increment\(1\),)",
            r"\1\n" + history_str,
            content
        )

    # 3. Redirect back to HomepageScreen
    # Handle both const Contents1() and const Contents1
    content = re.sub(
        r"Navigator\.pushReplacement\(context,\s*MaterialPageRoute\(builder:\s*\(_\)\s*=>\s*const\s+[A-Za-z0-9_]+(?:\(\))?\)\);",
        r"Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomepageScreen()), (route) => false);",
        content
    )

    # 4. If we replaced with HomepageScreen, ensure it's imported
    if 'const HomepageScreen()' in content and 'homepage_screen.dart' not in content:
        # Find the last import and add this import after it
        if 'import ' in content:
            content = re.sub(
                r"(import [^\n]+;)(?![\s\S]*import )",
                r"\1\n" + import_statement,
                content
            )
        else:
            content = import_statement + content

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Patched {filepath}")

for d in target_dirs:
    if not os.path.exists(d): continue
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

print("Patching complete.")
