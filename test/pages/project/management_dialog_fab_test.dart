import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:pathplanner/auto/pathplanner_auto.dart';
import 'package:pathplanner/commands/command_groups.dart';
import 'package:pathplanner/commands/named_command.dart';
import 'package:pathplanner/pages/project/mangement_dialog_fab.dart';
import 'package:pathplanner/pages/project/project_page.dart';
import 'package:pathplanner/path/event_marker.dart';
import 'package:pathplanner/path/pathplanner_path.dart';
import 'package:pathplanner/path/waypoint.dart';
import 'package:pathplanner/util/wpimath/geometry.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MemoryFileSystem fs;
  final String deployPath = Platform.isWindows ? 'C:\\deploy' : '/deploy';

  setUp(() async {
    fs = MemoryFileSystem(
        style: Platform.isWindows
            ? FileSystemStyle.windows
            : FileSystemStyle.posix);
  });

  testWidgets('event rename', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await widgetTester.binding.setSurfaceSize(const Size(1280, 720));

    await fs.directory(join(deployPath, 'paths')).create(recursive: true);
    await fs.directory(join(deployPath, 'autos')).create(recursive: true);

    ProjectPage.events.add('test1');

    PathPlannerPath path = PathPlannerPath.defaultPath(
      pathDir: join(deployPath, 'paths'),
      fs: fs,
    );
    path.eventMarkers.add(
      EventMarker(
        name: 'test1',
        command: SequentialCommandGroup(
          commands: [
            ParallelCommandGroup(
              commands: [
                NamedCommand(name: 'test1'),
              ],
            ),
          ],
        ),
      ),
    );
    path.generateAndSavePath();

    PathPlannerAuto auto = PathPlannerAuto.defaultAuto(
      autoDir: join(deployPath, 'autos'),
      fs: fs,
    );
    auto.sequence.commands.add(NamedCommand(name: 'test1'));
    auto.saveFile();

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ManagementDialogFAB(
          allPaths: [path],
          allAutos: [auto],
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final fab = find.byType(ManagementDialogFAB);

    expect(fab, findsOneWidget);

    await widgetTester.tap(fab);
    await widgetTester.pumpAndSettle();

    final renameBtn = find.descendant(
        of: find.widgetWithText(ListTile, 'test1'),
        matching: find.byTooltip('Rename event'));
    expect(renameBtn, findsOneWidget);

    await widgetTester.tap(renameBtn);
    await widgetTester.pumpAndSettle();

    final textField = find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(TextField));

    await widgetTester.enterText(textField, 'test1renamed');
    await widgetTester.pump();

    final confirmBtn = find.text('Confirm');

    await widgetTester.tap(confirmBtn);
    await widgetTester.pumpAndSettle();
  });

  testWidgets('linked waypoint rename', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await widgetTester.binding.setSurfaceSize(const Size(1280, 720));

    await fs.directory(join(deployPath, 'paths')).create(recursive: true);
    await fs.directory(join(deployPath, 'autos')).create(recursive: true);

    ProjectPage.events.add('test1');
    Waypoint.linked['link1'] = const Translation2d(0, 0);

    PathPlannerPath path = PathPlannerPath.defaultPath(
      pathDir: join(deployPath, 'paths'),
      fs: fs,
    );
    path.waypoints[0].linkedName = 'link1';
    path.generateAndSavePath();

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ManagementDialogFAB(
          allPaths: [path],
          allAutos: const [],
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final fab = find.byType(ManagementDialogFAB);

    expect(fab, findsOneWidget);

    await widgetTester.tap(fab);
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.text('Manage Linked Waypoints'));
    await widgetTester.pumpAndSettle();

    final renameBtn = find.descendant(
        of: find.widgetWithText(ListTile, 'link1'),
        matching: find.byTooltip('Rename linked waypoint'));
    expect(renameBtn, findsOneWidget);

    await widgetTester.tap(renameBtn);
    await widgetTester.pumpAndSettle();

    final textField = find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(TextField));

    await widgetTester.enterText(textField, 'link1renamed');
    await widgetTester.pump();

    final confirmBtn = find.text('Confirm');

    await widgetTester.tap(confirmBtn);
    await widgetTester.pumpAndSettle();
  });

  testWidgets('event remove', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await widgetTester.binding.setSurfaceSize(const Size(1280, 720));

    await fs.directory(join(deployPath, 'paths')).create(recursive: true);
    await fs.directory(join(deployPath, 'autos')).create(recursive: true);

    ProjectPage.events.add('test1');

    PathPlannerPath path = PathPlannerPath.defaultPath(
      pathDir: join(deployPath, 'paths'),
      fs: fs,
    );
    path.eventMarkers.add(
      EventMarker(
        name: 'test1',
        command: SequentialCommandGroup(
          commands: [
            ParallelCommandGroup(
              commands: [
                NamedCommand(name: 'test1'),
              ],
            ),
          ],
        ),
      ),
    );
    path.generateAndSavePath();

    PathPlannerAuto auto = PathPlannerAuto.defaultAuto(
      autoDir: join(deployPath, 'autos'),
      fs: fs,
    );
    auto.sequence.commands.add(NamedCommand(name: 'test1'));
    auto.saveFile();

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ManagementDialogFAB(
          allPaths: [path],
          allAutos: [auto],
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final fab = find.byType(ManagementDialogFAB);

    expect(fab, findsOneWidget);

    await widgetTester.tap(fab);
    await widgetTester.pumpAndSettle();

    final removeBtn = find.descendant(
        of: find.widgetWithText(ListTile, 'test1'),
        matching: find.byTooltip('Remove event'));
    expect(removeBtn, findsOneWidget);

    await widgetTester.tap(removeBtn);
    await widgetTester.pumpAndSettle();

    final confirmBtn = find.text('Confirm');

    await widgetTester.tap(confirmBtn);
    await widgetTester.pumpAndSettle();
  });

  testWidgets('linked waypoint remove', (widgetTester) async {
    FlutterError.onError = ignoreOverflowErrors;
    await widgetTester.binding.setSurfaceSize(const Size(1280, 720));

    await fs.directory(join(deployPath, 'paths')).create(recursive: true);
    await fs.directory(join(deployPath, 'autos')).create(recursive: true);

    Waypoint.linked['link1'] = const Translation2d(0, 0);

    PathPlannerPath path = PathPlannerPath.defaultPath(
      pathDir: join(deployPath, 'paths'),
      fs: fs,
    );
    path.waypoints[0].linkedName = 'link1';
    path.generateAndSavePath();

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ManagementDialogFAB(
          allPaths: [path],
          allAutos: const [],
        ),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final fab = find.byType(ManagementDialogFAB);

    expect(fab, findsOneWidget);

    await widgetTester.tap(fab);
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.text('Manage Linked Waypoints'));
    await widgetTester.pumpAndSettle();

    final removeBtn = find.descendant(
        of: find.widgetWithText(ListTile, 'link1'),
        matching: find.byTooltip('Remove linked waypoint'));
    expect(removeBtn, findsOneWidget);

    await widgetTester.tap(removeBtn);
    await widgetTester.pumpAndSettle();

    final confirmBtn = find.text('Confirm');

    await widgetTester.tap(confirmBtn);
    await widgetTester.pumpAndSettle();
  });
}
