import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/company_settings.dart';

class CompanySettingsRemoteDataSource {
  CompanySettingsRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<CompanySettings> fetchSettings() async {
    dbgAdmin('fetchCompanySettings start');
    try {
      final settingsRow = await _client
          .from('company_settings')
          .select('vat_rate, agreement_terms_ar')
          .eq('id', 1)
          .maybeSingle();
      final phoneRows = await _client
          .from('company_contact_phones')
          .select('id, label, phone, sort_order, show_on_pdf')
          .order('sort_order')
          .order('created_at');

      final vatRate = _asDouble(settingsRow?['vat_rate'], fallback: 0.15);
      final phones = (phoneRows as List<dynamic>)
          .map((row) => _mapPhone(row as Map<String, dynamic>))
          .toList(growable: false);
      dbgAdmin('fetchCompanySettings ok phones=${phones.length}');
      return CompanySettings(
        vatRate: vatRate,
        phones: phones,
        agreementTermsAr: (settingsRow?['agreement_terms_ar'] as String?) ?? '',
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'fetchCompanySettings',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CompanySettings> updateVatRate(double vatRate) async {
    dbgAdmin('updateVatRate start rate=$vatRate');
    try {
      await _client
          .from('company_settings')
          .update({'vat_rate': vatRate})
          .eq('id', 1);
      return fetchSettings();
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'updateVatRate',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CompanySettings> updateAgreementTerms(String terms) async {
    dbgAdmin('updateAgreementTerms start');
    try {
      await _client
          .from('company_settings')
          .update({'agreement_terms_ar': terms.trim()})
          .eq('id', 1);
      return fetchSettings();
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'updateAgreementTerms',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CompanySettings> savePhone(CompanyContactPhoneDraft draft) async {
    dbgAdmin('saveCompanyPhone start id=${draft.id}');
    try {
      final payload = {
        'label': draft.label.trim(),
        'phone': draft.phone.trim(),
        'sort_order': draft.sortOrder,
        'show_on_pdf': draft.showOnPdf,
      };
      if (draft.id == null) {
        await _client.from('company_contact_phones').insert(payload);
      } else {
        await _client
            .from('company_contact_phones')
            .update(payload)
            .eq('id', draft.id!);
      }
      return fetchSettings();
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'saveCompanyPhone',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CompanySettings> deletePhone(String phoneId) async {
    dbgAdmin('deleteCompanyPhone start id=$phoneId');
    try {
      await _client.from('company_contact_phones').delete().eq('id', phoneId);
      return fetchSettings();
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'AdminFlow',
        step: 'deleteCompanyPhone',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  CompanyContactPhone _mapPhone(Map<String, dynamic> row) {
    return CompanyContactPhone(
      id: row['id'] as String,
      label: (row['label'] as String?) ?? 'هاتف',
      phone: (row['phone'] as String?) ?? '',
      sortOrder: row['sort_order'] is num
          ? (row['sort_order'] as num).toInt()
          : 0,
      showOnPdf: (row['show_on_pdf'] as bool?) ?? true,
    );
  }

  double _asDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }
}
