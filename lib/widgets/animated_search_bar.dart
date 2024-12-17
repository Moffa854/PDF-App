import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onChanged;

  const AnimatedSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final _controller = TextEditingController();
  bool _isExpanded = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _isExpanded = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(29),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isExpanded ? 0 : 56,
                    child: _isExpanded
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              setState(() => _isExpanded = true);
                              _focusNode.requestFocus();
                            },
                          ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                        hintText: 'Search PDFs...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: _isExpanded ? 16 : 0,
                          right: 16,
                        ),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
