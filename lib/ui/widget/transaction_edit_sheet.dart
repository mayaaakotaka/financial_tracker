import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/transaction_entity.dart';
import '../../common/patterns/command.dart';

class TransactionEditSheet extends StatefulWidget {
  final TransactionEntity transaction;
  final Command1<void, dynamic, TransactionEntity> onSubmit;

  const TransactionEditSheet({
    super.key,
    required this.transaction,
    required this.onSubmit,
  });

  static void show({
    required BuildContext context,
    required TransactionEntity transaction,
    required Command1<void, dynamic, TransactionEntity> onSubmit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionEditSheet(
        transaction: transaction,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<TransactionEditSheet> createState() => _TransactionEditSheetState();
}

class _TransactionEditSheetState extends State<TransactionEditSheet> {
  String? title;
  String? amount;
  DateTime? date;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    title = widget.transaction.title;
    amount = widget.transaction.amount.toStringAsFixed(2);
    date = widget.transaction.date;
  }

  void _finalizar() {
    if (_formKey.currentState?.validate() ?? false) {
      final nova = widget.transaction.copyWith(
        title: title!.trim(),
        amount: double.parse(amount!),
        date: date!,
      );

      widget.onSubmit.execute(nova);
      Navigator.pop(context);
    }
  }

  void _abrirCalendario() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: date!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selecionada != null) {
      setState(() => date = selecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Alterar Transação', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (value) => title = value,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Insira um título' : null,
              ),
              TextFormField(
                initialValue: amount,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor'),
                onChanged: (value) => amount = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Digite um valor';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Data: ${formatter.format(date!)}'),
                  ),
                  TextButton(
                    onPressed: _abrirCalendario,
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _finalizar,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
