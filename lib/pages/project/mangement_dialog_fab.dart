import 'package:flutter/material.dart';
import 'package:pathplanner/auto/pathplanner_auto.dart';
import 'package:pathplanner/commands/command.dart';
import 'package:pathplanner/commands/command_groups.dart';
import 'package:pathplanner/commands/named_command.dart';
import 'package:pathplanner/path/pathplanner_path.dart';
import 'package:pathplanner/path/waypoint.dart';
import 'package:pathplanner/util/wpimath/geometry.dart';
import 'package:pathplanner/widgets/dialogs/management_dialog.dart';

class ManagementDialogFAB extends StatelessWidget {
  final List<PathPlannerPath> allPaths;
  final List<PathPlannerAuto> allAutos;

  const ManagementDialogFAB({
    super.key,
    required this.allPaths,
    required this.allAutos,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      clipBehavior: Clip.antiAlias,
      tooltip: 'Manage Events & Linked Waypoints',
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => ManagementDialog(
          onEventRenamed: (String oldName, String newName) {
            for (final path in allPaths) {
              for (final marker in path.eventMarkers) {
                _replaceNamedCommand(oldName, newName, marker.command);
                if (marker.name == oldName) {
                  marker.name = newName;
                }
              }
              path.saveFile();
            }

            for (PathPlannerAuto auto in allAutos) {
              for (Command cmd in auto.sequence.commands) {
                _replaceNamedCommand(oldName, newName, cmd);
              }
              auto.saveFile();
            }
          },
          onEventDeleted: (String name) {
            for (final path in allPaths) {
              for (final marker in path.eventMarkers) {
                _replaceNamedCommand(name, null, marker.command);
                if (marker.name == name) {
                  marker.name = '';
                }
              }
              path.saveFile();
            }

            for (PathPlannerAuto auto in allAutos) {
              for (Command cmd in auto.sequence.commands) {
                _replaceNamedCommand(name, null, cmd);
              }
              auto.saveFile();
            }
          },
          onLinkedRenamed: (String oldName, String newName) {
            Translation2d? pos = Waypoint.linked.remove(oldName);

            if (pos != null) {
              Waypoint.linked[newName] = pos;

              for (PathPlannerPath path in allPaths) {
                bool changed = false;

                for (Waypoint w in path.waypoints) {
                  if (w.linkedName == oldName) {
                    w.linkedName = newName;
                    changed = true;
                  }
                }

                if (changed) {
                  path.saveFile();
                }
              }
            }
          },
          onLinkedDeleted: (String name) {
            Waypoint.linked.remove(name);

            for (PathPlannerPath path in allPaths) {
              bool changed = false;

              for (Waypoint w in path.waypoints) {
                if (w.linkedName == name) {
                  w.linkedName = null;
                  changed = true;
                }
              }

              if (changed) {
                path.saveFile();
              }
            }
          },
        ),
      ),
      // Dumb hack to get an elevation surface tint
      child: Stack(
        children: [
          Container(
            color: colorScheme.surfaceTint.withOpacity(0.1),
          ),
          const Center(child: Icon(Icons.edit_note_rounded)),
        ],
      ),
    );
  }

  void _replaceNamedCommand(
      String originalName, String? newName, Command? command) {
    if (command == null) {
      return;
    }

    if (command is NamedCommand && command.name == originalName) {
      command.name = newName;
    } else if (command is CommandGroup) {
      for (Command cmd in command.commands) {
        _replaceNamedCommand(originalName, newName, cmd);
      }
    }
  }
}
