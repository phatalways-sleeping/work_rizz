import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:task_managing_application/apis/storage/crud.dart';
import 'package:task_managing_application/models/models.dart';

final class PdfAPI {
  const PdfAPI._();

  static Future<File> savePdfDocument({
    required String name,
    required Document document,
  }) async {
    final bytes = await document.save();
    final String filePath = '/storage/emulated/0/Download/$name.pdf';
    final file = File(filePath);

    await file.writeAsBytes(bytes);
    return file;
  }

  static final SizedBox _conjunctionLine = SizedBox(
    height: 0.5 * PdfPageFormat.cm,
  );

  static final SizedBox _bigConjunctionLine = SizedBox(
    height: 1.0 * PdfPageFormat.cm,
  );

  static const List<String> headerRow = [
    'Name',
    'Description',
    'Assignee',
    'Due Date',
    'Points',
    'Progress',
    "Leader's Review",
    "Grade",
  ];

  static Future<void> openFile(File file) async => OpenFile.open(file.path);

  static Future<File> buildReport(String projectId) async {
    final theme = ThemeData.withFont(
      base: Font.ttf(await rootBundle
          .load('assets/fonts/Montserrat/Montserrat-Regular.ttf')),
      bold: Font.ttf(
          await rootBundle.load('assets/fonts/Montserrat/Montserrat-Bold.ttf')),
      italic: Font.ttf(await rootBundle
          .load('assets/fonts/Montserrat/Montserrat-Italic.ttf')),
      boldItalic: Font.ttf(await rootBundle
          .load('assets/fonts/Montserrat/Montserrat-BoldItalic.ttf')),
    );
    final Document document = Document(
      theme: theme,
      pageMode: PdfPageMode.fullscreen,
      compress: true,
    );

    final Project project = await ReadProject.projectStream(projectId).first;

    final String leader =
        await ReadUser.userStreamById(project.leader).first.then(
              (value) => value.email,
            );

    final List<String> assignees = await Future.wait(
      project.assignees.map(
        (assigneeId) async => await ReadUser.userStreamById(assigneeId).first,
      ),
    ).then(
      (value) => value.map((user) => user.email).toList(),
    );

    final List<Widget> taskList = await Future.wait<Widget>(
      project.tasks.map(
        (taskId) async => await _buildTaskList(taskId)
            .onError((error, stackTrace) => Text('Error at task $taskId')),
      ),
    ).then(
      (value) => value,
    );

    // Header of the document
    document.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 1.5 * PdfPageFormat.cm,
        ),
        margin: const EdgeInsets.all(0.3 * PdfPageFormat.cm),
        theme: theme,
        footer: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bigConjunctionLine,
            Text(
              'Project Report',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            _conjunctionLine,
            Text(
              'Generated by Task Managing Application',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        build: (context) => [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _bigConjunctionLine,
              RichText(
                text: TextSpan(
                  text: 'Leader: ',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: leader,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              _conjunctionLine,
              RichText(
                text: TextSpan(
                  text: 'Tags: ',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    ...project.tags.map(
                      (tag) => TextSpan(
                        text: '${tag.title}, ',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _conjunctionLine,
              Text(
                'Assignees: ${assignees.join(', ')}',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              _conjunctionLine,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Start Date: ${project.endDate.month} / ${project.endDate.day} / ${project.endDate.year}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Duration: ${project.endDate.difference(project.startDate).inDays} days',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                ],
              ),
            ],
          ),
          _bigConjunctionLine,
          ...taskList.map(
            (e) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                e,
                _conjunctionLine,
              ],
            ),
          ),
          _bigConjunctionLine,
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Actitivies: ${project.totalActivities}',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _conjunctionLine,
                Text(
                  'Activities Completed: ${project.activitiesCompleted}',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _conjunctionLine,
                SizedBox(
                  width: 10 * PdfPageFormat.cm,
                  child: Divider(
                    color: PdfColors.black,
                    thickness: 1.0,
                  ),
                ),
                Text(
                  'Completion: ${(project.activitiesCompleted / project.totalActivities * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final File file = await savePdfDocument(
      name: project.name.trim().split(' ').join('_'),
      document: document,
    );

    return file;
  }

  static Future<Widget> _buildTaskList(String taskId) async {
    final Task taskModel = await ReadTask.taskStreamById(taskId).first;

    final List<SubTaskModel> subtaskList = await Future.wait<SubTaskModel>(
      taskModel.subTasks.map(
        (subtaskId) async =>
            ReadSubTask.subTaskModelStreamById(subtaskId).first,
      ),
    ).then(
      (value) => value,
    );

    final List<SubTaskModel> subtaskWithEmailList =
        await Future.wait<SubTaskModel>(
      subtaskList.map(
        (subtask) async {
          final String email =
              await ReadUser.userStreamById(subtask.assignee).first.then(
                    (value) => value.email,
                  );
          return subtask.copyWith(assignee: email);
        },
      ),
    ).then(
      (value) => value,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          taskModel.name,
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
        ),
        _conjunctionLine,
        Table(
          tableWidth: TableWidth.max,
          border: TableBorder.all(
            color: PdfColors.black,
            width: 1.0,
          ),
          columnWidths: {
            0: const FlexColumnWidth(1),
            1: const FlexColumnWidth(2),
            2: const FlexColumnWidth(1),
            3: const FlexColumnWidth(1),
            4: const FlexColumnWidth(1),
            5: const FlexColumnWidth(1),
            6: const FlexColumnWidth(1),
            7: const FlexColumnWidth(1),
          },
          children: [
            // Table Header
            TableRow(
              verticalAlignment: TableCellVerticalAlignment.middle,
              decoration: const BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: [
                ...headerRow.map(
                  (header) => Text(
                    header,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Table Body
            ...subtaskWithEmailList.map(
              (subtask) => TableRow(
                verticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      subtask.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      subtask.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      subtask.assignee,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '${subtask.dueDate.month} / ${subtask.dueDate.day} / ${subtask.dueDate.year}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '${subtask.points}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '${subtask.progress}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      subtask.leaderComment.isEmpty
                          ? 'Not yet'
                          : subtask.leaderComment,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      subtask.isCompleted ? '${subtask.grade}' : 'Not yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
