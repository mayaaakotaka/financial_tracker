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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
        text: widget.transaction.amount.toStringAsFixed(2));
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.transaction.copyWith(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
      );

      widget.onSubmit.execute(updated);
      Navigator.of(context).pop();
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
          child: Wrap(
            runSpacing: 16,
            children: [
              Text(
                'Editar Transação',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Insira um título válido'
                        : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira um valor';
                  }
                  final amount = double.tryParse(value);
                  return (amount == null || amount <= 0)
                      ? 'Valor inválido'
                      : null;
                },
              ),
              Row(
                children: [
                  Expanded(child: Text('Data: ${formatter.format(_selectedDate)}')),
                  TextButton(
                    onPressed: _handlePickDate,
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleCancel,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Concluir'),
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
