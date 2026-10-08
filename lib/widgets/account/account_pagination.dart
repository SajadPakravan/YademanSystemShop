import 'package:flutter/material.dart';
import 'package:yad_sys/view_models/account/profile/account_list_view_model.dart';

class AccountPagination extends StatelessWidget {
  const AccountPagination({super.key, required this.viewModel, required this.child});
  final AccountListViewModel<dynamic> viewModel;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: child),
    if (viewModel.items.isNotEmpty && (viewModel.pagination.hasNext || viewModel.errorMessage.isNotEmpty))
      Material(color: Theme.of(context).scaffoldBackgroundColor, child: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (viewModel.errorMessage.isNotEmpty) Text(viewModel.errorMessage, textAlign: TextAlign.center),
          if (viewModel.isLoadingMore) const LinearProgressIndicator()
          else TextButton(onPressed: viewModel.isLoading || viewModel.isRefreshing ? null : (viewModel.pagination.hasNext ? viewModel.loadMore : viewModel.refresh), child: Text(viewModel.pagination.hasNext ? 'نمایش بیشتر' : 'تلاش دوباره')),
        ]),
      ))),
  ]);
}
