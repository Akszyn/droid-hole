import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddDomainModal extends StatefulWidget {
  final String selectedlist;
  final void Function(Map<String, dynamic>) addDomain;

  const AddDomainModal({
    Key? key,
    required this.selectedlist,
    required this.addDomain,
  }) : super(key: key);

  @override
  State<AddDomainModal> createState() => _AddDomainModalState();
}

enum ListType { whitelist, blacklist }

class _AddDomainModalState extends State<AddDomainModal> {
  final TextEditingController domainController = TextEditingController();
  String? domainError; 
  ListType selectedType = ListType.whitelist;
  bool wildcard = false;
  bool allDataValid = false;

  @override
  void initState() {
    selectedType = widget.selectedlist == 'whitelist' 
      ? ListType.whitelist : ListType.blacklist;
    super.initState();
  }

  String getSelectedList() {
    if (selectedType == ListType.whitelist && wildcard == false) {
      return "white";
    }
    else if (selectedType == ListType.whitelist && wildcard == true) {
      return "regex_white";
    }
    if (selectedType == ListType.blacklist && wildcard == false) {
      return "black";
    }
    else if (selectedType == ListType.blacklist && wildcard == true) {
      return "regex_black";
    }
    else {
      return "";
    }
  }

  String applyWildcard() {
    return "(\\.|^)${domainController.text.replaceAll('.', '\\.')}\$";
  }

  void validateDomain(String? value) {
    if (value != null && value != '') {
      RegExp subrouteRegexp = RegExp(r'^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9-_]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$');
      if (subrouteRegexp.hasMatch(value) == true) {
        setState(() {
          domainError = null;
        });
      }
      else {
        setState(() {
          domainError = AppLocalizations.of(context)!.invalidDomain;
        });
      }
    }
    else {
      setState(() {
        domainError = null;
      });
    }
    validateAllData();
  }

  void validateAllData() {
    if (
      domainController.text != '' &&
      domainError == null &&
      (selectedType == ListType.blacklist || selectedType == ListType.whitelist)
    ) {
      setState(() {
        allDataValid = true;
      });
    }
    else {
      setState(() {
        allDataValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: height > 466
          ? 466
          : height - 30,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28)
          )
        ),
        child: Column(
          children: [
            SizedBox(
              height: height < 448 
                ? MediaQuery.of(context).viewInsets.bottom > 0
                  ? height - MediaQuery.of(context).viewInsets.bottom - 48
                  : 241
                : null,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Icon(
                      Icons.domain_add_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        AppLocalizations.of(context)!.addDomain,
                        style: const TextStyle(
                          fontSize: 24
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.maxFinite,
                      child: SegmentedButton<ListType>(
                        segments: const [
                          ButtonSegment(
                            value: ListType.whitelist,
                            label: Text("Whitelist")
                          ),
                          ButtonSegment(
                            value: ListType.blacklist,
                            label: Text("Blacklist")
                          ),
                        ], 
                        selected: <ListType>{selectedType},
                        onSelectionChanged: (value) => setState(() => selectedType = value.first),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.only(top: 20),
                      child: TextField(
                        controller: domainController,
                        onChanged: (value) => validateDomain(value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.domain_rounded),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10)
                            )
                          ),
                          labelText: AppLocalizations.of(context)!.domain,
                          errorText: domainError
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.addAsWildcard,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal
                        ),
                      ),
                      value: wildcard, 
                      onChanged: (value) => {
                        setState((() => wildcard = value))
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.cancel)
                        ),
                        const SizedBox(width: 14),
                        TextButton(
                          onPressed: allDataValid == true
                            ? () {
                                widget.addDomain({
                                  'list': getSelectedList(),
                                  'domain': wildcard == true
                                    ? applyWildcard()
                                    : domainController.text,
                                });
                                Navigator.pop(context);
                              } 
                            : null,
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                              allDataValid == true
                                ? null
                                : Colors.grey
                            )
                          ),
                          child: Text(AppLocalizations.of(context)!.add),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}