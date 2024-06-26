// src/home/components/_search_button.dart
import 'package:flutter/material.dart';
import 'package:pcic_mobile_app/src/theme/_theme.dart';

class SearchButton extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onUpdateValue;

  const SearchButton({
    super.key,
    required this.searchQuery,
    required this.onUpdateValue,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(SearchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<CustomThemeExtension>();
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14), // Changed from 32.0 to 8.0
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(14), // Changed from 32.0 to 8.0
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    widget.onUpdateValue(value);
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 87, 87, 87),
                    fontSize: t?.caption,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Task',
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 87, 87, 87),
                        fontSize: t?.caption),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                      child: _isSearching
                          ? const Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 87, 87, 87),
                              size: 30,
                            )
                          : const Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 87, 87, 87),
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
