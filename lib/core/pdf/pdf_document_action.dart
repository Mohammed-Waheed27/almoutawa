/// How to deliver a generated commercial PDF from the UI.
enum PdfDocumentAction {
  /// Persist to app documents (save only).
  save,

  /// System share sheet (share only).
  share,

  /// System print / save-as preview.
  preview,

  /// Share PDF toward WhatsApp for the client phone.
  whatsapp,
}
