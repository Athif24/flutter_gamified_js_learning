# Read the file and fix the _filterCourses calls
with open('lib/features/courses/presentation/screens/course_list_screen.dart', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Fix the call in hero banner section (3 args -> 4 args)
content = content.replace(
    'final filtered = _filterCourses(courses, searchQuery, filter);',
    'final filtered = _filterCourses(courses, searchQuery, filter, {});'
)

with open('lib/features/courses/presentation/screens/course_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed _filterCourses call in hero banner")
