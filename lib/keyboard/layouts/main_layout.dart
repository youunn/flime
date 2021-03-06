import 'package:auto_route/auto_route.dart';
import 'package:flime/api/platform_api.g.dart';
import 'package:flime/keyboard/base/event.dart';
import 'package:flime/keyboard/components/keyboard_wrapper.dart';
import 'package:flime/keyboard/services/input_service.dart';
import 'package:flime/keyboard/stores/constraint.dart';
import 'package:flime/keyboard/stores/keyboard_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Consumer<ConstraintStore>(
          builder: (context, constraint, child) {
            return Observer(
              builder: (context) {
                return SizedBox(
                  height: constraint.totalHeight,
                  child: Material(
                    color: Colors.black,
                    child: child,
                  ),
                );
              },
            );
          },
          child: Consumer2<KeyboardStatus, ConstraintStore>(
            builder: (_, status, constraint, __) {
              return Builder(
                builder: (context) {
                  final orientation = MediaQuery.of(context).orientation;
                  if (constraint.orientation != orientation) {
                    constraint.orientation = orientation;
                  }

                  return Column(
                    children: [
                      ToolbarWrapper(
                        child: Observer(
                          builder: (context) {
                            final width = MediaQuery.of(context).size.width;
                            final orientationFactor =
                                orientation == Orientation.landscape ? constraint.orientationFactor : 1;
                            return SizedBox(
                              height: constraint.toolbarHeightFactor * width * orientationFactor,
                              child: status.isComposing ? const Candidates() : const Toolbar(),
                            );
                          },
                        ),
                      ),
                      const Expanded(
                        child: AutoRouter(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            child: const Center(
              child: Icon(Icons.keyboard_arrow_left),
            ),
            onTap: () {
              final event = KEvent(key: LogicalKeyboardKey.goBack);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: const Center(
              child: Icon(Icons.keyboard),
            ),
            onTap: () {
              // pick other ime
              context.read<InputMethodApi>().pick();
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: const Center(
              child: Icon(Icons.translate),
            ),
            onTap: () {
              // schema options
              final event = KEvent(key: LogicalKeyboardKey.backquote, mask: KEvent.modifierControl);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: Center(
              child: Consumer<KeyboardStatus>(
                builder: (_, status, __) {
                  return Observer(
                    builder: (_) {
                      return Icon(status.isAsciiMode ? Icons.language : Icons.edit);
                    },
                  );
                },
              ),
            ),
            onTap: () {
              // mode switch
              final event = KEvent(key: LogicalKeyboardKey.digit2, mask: KEvent.modifierControl | KEvent.modifierShift);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: const Center(
              child: Icon(Icons.settings),
            ),
            onTap: () {
              // left
              final event = KEvent(key: LogicalKeyboardKey.arrowLeft);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: const Center(
              child: Icon(Icons.more_horiz),
            ),
            onTap: () {
              // right
              final event = KEvent(key: LogicalKeyboardKey.arrowRight);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
        Expanded(
          child: InkWell(
            child: const Center(
              child: Icon(Icons.mic),
            ),
            onTap: () {
              context.read<LayoutApi>().toggleFullScreen();
            },
          ),
        ),
      ],
    );
  }
}

class Candidates extends StatelessWidget {
  const Candidates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: InkWell(
            child: Center(
              child: Consumer<KeyboardStatus>(
                builder: (_, status, __) {
                  return Observer(
                    builder: (context) {
                      return Text(
                        status.preedit ?? status.preview ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  );
                },
              ),
            ),
            onTap: () {
              final event = KEvent(key: LogicalKeyboardKey.pageUp);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
        Expanded(
          flex: 5,
          child: Consumer<KeyboardStatus>(
            builder: (_, status, __) {
              return Observer(
                builder: (context) {
                  return Row(
                    children: [
                      for (var i = 0; i < status.candidates.length; i++) ...[
                        SizedBox(
                          width: 1,
                          child: FractionallySizedBox(
                            heightFactor: 0.5,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    status.candidates[i] ?? '',
                                    style: (status.candidates[i]?.length ?? 0) <= 2
                                        ? TextStyle(fontSize: Theme.of(context).textTheme.headline6?.fontSize)
                                        : TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
                                  ),
                                  if (status.comments[i]?.isNotEmpty == true)
                                    Text(
                                      status.comments[i] ?? '',
                                      style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                                    ),
                                ],
                              ),
                            ),
                            onTap: () {
                              final event = KEvent.number(i + 1);
                              context.read<InputService>().handleEvent(event, context);
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            child: const Center(
              child: Icon(Icons.keyboard_arrow_right),
            ),
            onTap: () {
              final event = KEvent(key: LogicalKeyboardKey.pageDown);
              context.read<InputService>().handleEvent(event, context);
            },
          ),
        ),
      ],
    );
  }
}
