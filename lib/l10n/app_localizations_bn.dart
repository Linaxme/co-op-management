// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'কোঅপারেটিভ ম্যানেজমেন্ট';

  @override
  String get dashboard => 'ড্যাশবোর্ড';

  @override
  String get members => 'সদস্য';

  @override
  String get due => 'বকেয়া';

  @override
  String get reports => 'রিপোর্ট';

  @override
  String get settings => 'সেটিংস';

  @override
  String get trash => 'ট্র্যাশ';

  @override
  String get addDeposit => 'ডিপোজিট যোগ করুন';

  @override
  String get addMember => 'সদস্য যোগ করুন';

  @override
  String get editMember => 'সদস্য সম্পাদনা করুন';

  @override
  String get memberDetails => 'সদস্যের বিবরণ';

  @override
  String get dueReport => 'বকেয়া রিপোর্ট';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get delete => 'মুছুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get required => 'আবশ্যক';

  @override
  String get search => 'খুঁজুন';

  @override
  String get searchBy => 'নাম / সদস্য আইডি / ফোন দিয়ে খুঁজুন';

  @override
  String get totalCollection => 'মোট সংগ্রহ';

  @override
  String get totalDue => 'মোট বকেয়া';

  @override
  String get collection => 'সংগ্রহ';

  @override
  String currentMonth(String month) {
    return 'বর্তমান মাস ($month)';
  }

  @override
  String monthPaymentStatus(String month) {
    return 'পেমেন্ট স্ট্যাটাস ($month)';
  }

  @override
  String get collectionByMonth => 'মাস অনুযায়ী সংগ্রহ';

  @override
  String get noMembersYet => 'এখনো কোনো সদস্য নেই';

  @override
  String get noMembersFound => 'কোনো সদস্য পাওয়া যায়নি';

  @override
  String get tapToAddFirstMember => '+ চাপুন আপনার প্রথম সদস্য যোগ করতে';

  @override
  String get addFirstMember => 'প্রথম সদস্য যোগ করুন';

  @override
  String get tryDifferentSearch => 'একটি ভিন্ন শব্দ দিয়ে চেষ্টা করুন';

  @override
  String get noDueMembers => 'কোনো বকেয়া সদস্য নেই';

  @override
  String get allMembersUpToDate => 'সব সদস্য তাদের পেমেন্ট আপ টু ডেট! 🎉';

  @override
  String get noDue => 'কোনো বকেয়া নেই';

  @override
  String get months => 'মাস';

  @override
  String get memberIdNumber => 'সদস্য আইডি নম্বর';

  @override
  String get name => 'নাম';

  @override
  String get phone => 'ফোন';

  @override
  String get phoneOptional => 'ফোন (ঐচ্ছিক)';

  @override
  String get address => 'ঠিকানা';

  @override
  String get addressOptional => 'ঠিকানা (ঐচ্ছিক)';

  @override
  String get nidNumber => 'এনআইডি নম্বর';

  @override
  String get nidNumberOptional => 'এনআইডি নম্বর (ঐচ্ছিক)';

  @override
  String get monthlyAmount => 'মাসিক পরিমাণ (টাকা)';

  @override
  String get addPhoto => 'ছবি যোগ করুন';

  @override
  String get removePhoto => 'ছবি সরান';

  @override
  String get memberTypeNameOrId => 'সদস্য (নাম বা আইডি টাইপ করুন)';

  @override
  String get memberCannotBeChanged => 'সদস্য (পরিবর্তন করা যাবে না)';

  @override
  String get date => 'তারিখ';

  @override
  String get amount => 'পরিমাণ (টাকা)';

  @override
  String get fromMonth => 'শুরু মাস';

  @override
  String get toMonth => 'শেষ মাস';

  @override
  String get toMonthOptional => 'শেষ মাস (ঐচ্ছিক)';

  @override
  String get selectMonth => 'মাস নির্বাচন করুন';

  @override
  String get selectMonthOptional => 'মাস নির্বাচন করুন (ঐচ্ছিক)';

  @override
  String get noneSingleMonth => 'কিছু নেই (এক মাস)';

  @override
  String get paymentMethod => 'পেমেন্ট পদ্ধতি';

  @override
  String get cash => 'নগদ';

  @override
  String get bkash => 'বিকাশ';

  @override
  String get nagad => 'নগদ';

  @override
  String get bank => 'ব্যাংক';

  @override
  String get receivedBy => 'গ্রহণ করেছেন';

  @override
  String get confirmDeposit => 'ডিপোজিট নিশ্চিত করুন';

  @override
  String depositAmount(String amount) {
    return 'ডিপোজিট পরিমাণ: $amount';
  }

  @override
  String member(String name) {
    return 'সদস্য: $name';
  }

  @override
  String get confirmGenerateReceipt =>
      'আপনি কি নিশ্চিত করতে এবং রসিদ তৈরি করতে চান?';

  @override
  String get confirmGenerateReceiptButton => 'নিশ্চিত করুন এবং রসিদ তৈরি করুন';

  @override
  String get depositConfirmed => 'ডিপোজিট নিশ্চিত হয়েছে। রসিদ তৈরি হয়েছে।';

  @override
  String get depositUpdated => 'ডিপোজিট সফলভাবে আপডেট হয়েছে';

  @override
  String get error => 'ত্রুটি';

  @override
  String get errorLoadingMember => 'সদস্য লোড করতে ত্রুটি';

  @override
  String get errorLoadingMembers => 'সদস্য লোড করতে ত্রুটি';

  @override
  String get invalidImagePath => 'অবৈধ ছবির পথ';

  @override
  String get selectedImageNotFound => 'নির্বাচিত ছবির ফাইল পাওয়া যায়নি';

  @override
  String errorCheckingFile(String error) {
    return 'ফাইল চেক করতে ত্রুটি: $error';
  }

  @override
  String errorAccessingDirectory(String error) {
    return 'ডিরেক্টরি অ্যাক্সেস করতে ত্রুটি: $error';
  }

  @override
  String errorCreatingFolder(String error) {
    return 'ফোল্ডার তৈরি করতে ত্রুটি: $error';
  }

  @override
  String errorSavingImage(String error) {
    return 'ছবি সংরক্ষণ করতে ত্রুটি: $error';
  }

  @override
  String unexpectedError(String error) {
    return 'অপ্রত্যাশিত ত্রুটি: $error';
  }

  @override
  String get memberSaved => 'সদস্য সফলভাবে সংরক্ষণ হয়েছে';

  @override
  String get memberUpdated => 'সদস্য সফলভাবে আপডেট হয়েছে';

  @override
  String get deleteMember => 'সদস্য মুছুন';

  @override
  String deleteMemberConfirm(String name) {
    return 'আপনি কি নিশ্চিত যে আপনি \"$name\" মুছতে চান? এটি সদস্যকে ট্র্যাশে সরিয়ে দেবে।';
  }

  @override
  String get memberDeleted => 'সদস্য সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get memberRestored => 'সদস্য সফলভাবে পুনরুদ্ধার হয়েছে';

  @override
  String get memberPermanentlyDeleted => 'সদস্য স্থায়ীভাবে মুছে ফেলা হয়েছে';

  @override
  String get depositDeleted => 'ডিপোজিট সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get depositRestored => 'ডিপোজিট সফলভাবে পুনরুদ্ধার হয়েছে';

  @override
  String get depositPermanentlyDeleted =>
      'ডিপোজিট স্থায়ীভাবে মুছে ফেলা হয়েছে';

  @override
  String get failedToLoadOrganization => 'সংস্থা লোড করতে ব্যর্থ';

  @override
  String get generalSettings => 'সাধারণ সেটিংস';

  @override
  String get organizationNameAndAddress => 'সংস্থার নাম এবং ঠিকানা';

  @override
  String get organizationName => 'সংস্থার নাম';

  @override
  String get enterOrganizationName => 'সংস্থার নাম লিখুন';

  @override
  String get organizationAddress => 'সংস্থার ঠিকানা';

  @override
  String get enterOrganizationAddress => 'সংস্থার ঠিকানা লিখুন';

  @override
  String get brandingIdentity => 'ব্র্যান্ডিং এবং পরিচয়';

  @override
  String get logoAndSignature => 'নথির জন্য লোগো এবং স্বাক্ষর';

  @override
  String get logo => 'লোগো';

  @override
  String get usedInReceiptsAndReports => 'রসিদ এবং রিপোর্টে ব্যবহৃত';

  @override
  String get signature => 'স্বাক্ষর';

  @override
  String get receiptConfiguration => 'রসিদ কনফিগারেশন';

  @override
  String get receiptSettings => 'রসিদ প্রিফিক্স এবং সিরিয়াল নম্বর সেটিংস';

  @override
  String get receiptPrefix => 'রসিদ প্রিফিক্স';

  @override
  String get defaultReceivedBy => 'ডিফল্ট গ্রহণকারী';

  @override
  String get appearance => 'চেহারা';

  @override
  String get themeAndLanguage => 'থিম মোড এবং ভাষা সেটিংস';

  @override
  String get themeMode => 'থিম মোড';

  @override
  String get light => 'হালকা';

  @override
  String get dark => 'অন্ধকার';

  @override
  String get auto => 'স্বয়ংক্রিয়';

  @override
  String get language => 'ভাষা';

  @override
  String get bengali => 'বাংলা';

  @override
  String get english => 'ইংরেজি';

  @override
  String get dataManagement => 'ডেটা ম্যানেজমেন্ট';

  @override
  String get backupAndRestore => 'আপনার ডেটা ব্যাকআপ এবং পুনরুদ্ধার করুন';

  @override
  String get exportBackup => 'ব্যাকআপ রপ্তানি করুন';

  @override
  String get importBackup => 'ব্যাকআপ আমদানি করুন';

  @override
  String get saveAllSettings => 'সব সেটিংস সংরক্ষণ করুন';

  @override
  String get settingsSaved => 'সেটিংস সফলভাবে সংরক্ষণ হয়েছে';

  @override
  String get backupExported => 'ব্যাকআপ সফলভাবে রপ্তানি হয়েছে';

  @override
  String get backupImported => 'ব্যাকআপ সফলভাবে আমদানি হয়েছে';

  @override
  String errorPickingImage(String error) {
    return 'ছবি নির্বাচন করতে ত্রুটি: $error';
  }

  @override
  String get annualReport => 'বার্ষিক রিপোর্ট';

  @override
  String get yearWiseSummary => 'বছর অনুযায়ী সংগ্রহ সারাংশ';

  @override
  String get memberReport => 'সদস্য রিপোর্ট';

  @override
  String get individualMemberDetails => 'ব্যক্তিগত সদস্যের বিবরণ এবং রিপোর্ট';

  @override
  String get monthlyReport => 'মাসিক রিপোর্ট';

  @override
  String get monthWiseCollection => 'মাস অনুযায়ী সংগ্রহ এবং সদস্যের অবস্থা';

  @override
  String get generatePdf => 'PDF তৈরি করুন';

  @override
  String get exportCsv => 'CSV রপ্তানি করুন';

  @override
  String get exportExcel => 'Excel রপ্তানি করুন';

  @override
  String get selectYear => 'বছর নির্বাচন করুন';

  @override
  String get selectMember => 'সদস্য নির্বাচন করুন';

  @override
  String get reportGenerated => 'রিপোর্ট সফলভাবে তৈরি হয়েছে';

  @override
  String get reportExported => 'রিপোর্ট সফলভাবে রপ্তানি হয়েছে';

  @override
  String get deletedMembers => 'মুছে ফেলা সদস্য';

  @override
  String get deletedDeposits => 'মুছে ফেলা ডিপোজিট';

  @override
  String get restore => 'পুনরুদ্ধার';

  @override
  String get permanentDelete => 'স্থায়ীভাবে মুছুন';

  @override
  String get emptyTrash => 'ট্র্যাশ খালি করুন';

  @override
  String get emptyTrashConfirm =>
      'আপনি কি নিশ্চিত যে আপনি ট্র্যাশের সব আইটেম স্থায়ীভাবে মুছতে চান? এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get trashEmptied => 'ট্র্যাশ সফলভাবে খালি করা হয়েছে';

  @override
  String get noDeletedMembers => 'কোনো মুছে ফেলা সদস্য নেই';

  @override
  String get noDeletedDeposits => 'কোনো মুছে ফেলা ডিপোজিট নেই';

  @override
  String get memberId => 'সদস্য আইডি';

  @override
  String phoneLabel(String phone) {
    return 'ফোন: $phone';
  }

  @override
  String addressLabel(String address) {
    return 'ঠিকানা: $address';
  }

  @override
  String nidLabel(String nid) {
    return 'এনআইডি: $nid';
  }

  @override
  String monthlyAmountLabel(String amount) {
    return 'মাসিক পরিমাণ: $amount';
  }

  @override
  String get balanceSummary => 'ব্যালেন্স সারাংশ';

  @override
  String get totalDeposited => 'মোট জমা';

  @override
  String get expectedTotal => 'প্রত্যাশিত মোট';

  @override
  String get netDueAdvance => 'নেট বকেয়া/অগ্রিম';

  @override
  String get deposits => 'ডিপোজিট';

  @override
  String get filterByDate => 'তারিখ দিয়ে ফিল্টার করুন';

  @override
  String get all => 'সব';

  @override
  String get thisMonth => 'এই মাস';

  @override
  String get lastMonth => 'গত মাস';

  @override
  String get customRange => 'কাস্টম রেঞ্জ';

  @override
  String get selectStartDate => 'শুরু তারিখ নির্বাচন করুন';

  @override
  String get selectEndDate => 'শেষ তারিখ নির্বাচন করুন';

  @override
  String get depositHistory => 'ডিপোজিট ইতিহাস';

  @override
  String get noDeposits => 'কোনো ডিপোজিট নেই';

  @override
  String get receiptNumber => 'রসিদ নম্বর';

  @override
  String get method => 'পদ্ধতি';

  @override
  String get reason => 'কারণ';

  @override
  String duplicateDepositError(String month) {
    return 'এই মাসের জন্য ইতিমধ্যে ডিপোজিট করা হয়েছে: $month। একই মাসের জন্য একাধিক ডিপোজিট করা যাবে না।';
  }

  @override
  String duplicateDepositsError(String months) {
    return 'এই মাসগুলোর জন্য ইতিমধ্যে ডিপোজিট করা হয়েছে: $months। একই মাসের জন্য একাধিক ডিপোজিট করা যাবে না।';
  }

  @override
  String get adminLogin => 'অ্যাডমিন';

  @override
  String get memberLogin => 'সদস্য';

  @override
  String get loginWelcome => 'স্বাগতম';

  @override
  String get loginSubtitleMember => 'সমিতির শর্ট নেম দিয়ে লগইন করুন';

  @override
  String get loginSubtitleAdmin => 'সমিতি পরিচালনার জন্য লগইন করুন';

  @override
  String get loginSwitchToAdmin => 'অ্যাডমিন লগইন';

  @override
  String get loginSwitchToMember => 'সদস্য লগইন';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get pin => 'পিন';

  @override
  String get login => 'লগইন';

  @override
  String get logout => 'লগআউট';

  @override
  String get loginFailed => 'লগইন ব্যর্থ। তথ্য যাচাই করুন।';

  @override
  String get passwordLengthHint => 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';

  @override
  String get defaultMemberPassword => 'ডিফল্ট মেম্বার পাসওয়ার্ড';

  @override
  String get defaultMemberPasswordHint =>
      'নতুন মেম্বার যোগ করলে এই পাসওয়ার্ড ব্যবহার হবে';

  @override
  String get changePassword => 'পাসওয়ার্ড পরিবর্তন';

  @override
  String get currentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get newPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get passwordMismatch => 'পাসওয়ার্ড মিলছে না';

  @override
  String get passwordChanged => 'পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে';

  @override
  String get myProfile => 'আমার প্রোফাইল';

  @override
  String get myDue => 'আমার বকেয়া';

  @override
  String get initialPin => 'প্রাথমিক পিন';

  @override
  String get resetPin => 'পিন রিসেট (ঐচ্ছিক)';

  @override
  String get resetPinHint => 'খালি রাখলে পুরনো পিন থাকবে';

  @override
  String get phoneAlreadyUsed => 'এই ফোন নম্বর ইতিমধ্যে নিবন্ধিত';

  @override
  String get noDueAmount => 'কোনো বকেয়া নেই। আপনি আপডেট আছেন।';

  @override
  String get errorLoadingData => 'ডেটা লোড করতে ব্যর্থ';

  @override
  String get theme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get signUp => 'সাইন আপ';

  @override
  String get signUpTitle => 'সমবায় নিবন্ধন';

  @override
  String get alreadyHaveAccount => 'অ্যাকাউন্ট আছে? লগইন করুন';

  @override
  String get dontHaveAccount => 'নতুন সমবায়? সাইন আপ করুন';

  @override
  String get cooperativeAlreadyRegistered =>
      'ইতিমধ্যে একটি সমবায় নিবন্ধিত। লগইন করুন।';

  @override
  String get signUpFailed => 'সাইন আপ ব্যর্থ। আবার চেষ্টা করুন।';

  @override
  String get memberLoginHint =>
      'ফোন নম্বরই ইউজারনেম। পাসওয়ার্ড অ্যাডমিনের দেওয়া ডিফল্ট পাসওয়ার্ড।';

  @override
  String get signUpSuccess => 'সমবায় সফলভাবে নিবন্ধিত হয়েছে';

  @override
  String get organizationShortName => 'সংস্থার শর্ট নেম';

  @override
  String get organizationShortNameHint => 'যেমন: SSF, BRAC';

  @override
  String get organizationShortNameHelper =>
      'সদস্যরা লগইনে এটি টাইপ করবে (২–১২ অক্ষর)';

  @override
  String get shortNameTaken => 'এই শর্ট নেম ইতিমধ্যে ব্যবহৃত';

  @override
  String get shortNameInvalid => '২–১২ অক্ষর, শুধু ইংরেজি অক্ষর ও সংখ্যা';

  @override
  String get memberLoginShortName => 'সমিতির শর্ট নেম';

  @override
  String get memberLoginShortNameHint => 'সমিতির শর্ট নেম লিখুন (যেমন SSF)';

  @override
  String get memberLoginConfirmOrg => 'লগইন করছেন';

  @override
  String get memberLoginContinue => 'এগিয়ে যান';

  @override
  String get memberLoginChangeOrg => 'সমিতি পরিবর্তন';

  @override
  String get memberShareShortName => 'সদস্যরা লগইনে এই শর্ট নেম টাইপ করবে';

  @override
  String get syncStatusSynced => 'সিঙ্ক হয়েছে';

  @override
  String get syncStatusSyncing => 'সিঙ্ক হচ্ছে…';

  @override
  String get syncStatusConnecting => 'সংযোগ হচ্ছে…';

  @override
  String get syncStatusError => 'সিঙ্ক ত্রুটি';

  @override
  String get syncStatusOffline => 'অফলাইন';

  @override
  String get settingsTabOrganization => 'সংস্থা';

  @override
  String get settingsTabReceipt => 'রসিদ';

  @override
  String get settingsTabMemberApp => 'সদস্য অ্যাপ';

  @override
  String get settingsTabSystem => 'সিস্টেম';

  @override
  String get setShortNameForLogin => 'সদস্য লগইনের জন্য শর্ট নেম সেট করুন';

  @override
  String get addLogo => 'লোগো যোগ করুন';

  @override
  String get removeLogo => 'লোগো সরান';

  @override
  String get signatureOnReceipts => 'রসিদের নিচে দেখাবে';

  @override
  String get tapAddSignature => 'স্বাক্ষরের ছবি যোগ করতে ট্যাপ করুন';

  @override
  String get removeSignature => 'স্বাক্ষর সরান';

  @override
  String get memberDashboardSettings => 'সদস্য ড্যাশবোর্ড';

  @override
  String get memberDashboardSettingsSubtitle => 'সদস্যরা কী দেখতে পাবে';

  @override
  String get coopCurrentMonth => 'সমিতির চলতি মাস';

  @override
  String get coopTotalCollection => 'সমিতির মোট জমা';

  @override
  String get coopTotalDue => 'সমিতির মোট বকেয়া';

  @override
  String get membersWithDueList => 'কার কার বকেয়া আছে';

  @override
  String get backupExportHint =>
      'ব্যাকআপের জন্য সব ডেটা JSON ফাইলে এক্সপোর্ট করুন। পরে পুনরুদ্ধার করতে পারবেন।';

  @override
  String get importBackupTitle => 'ব্যাকআপ ইম্পোর্ট';

  @override
  String get importBackupMessage =>
      'ব্যাকআপ ফাইল থেকে ডেটা ইম্পোর্ট হবে। একই UUID থাকলে মার্জ হবে। চালিয়ে যাবেন?';

  @override
  String get import => 'ইম্পোর্ট';

  @override
  String get couldNotReadBackup => 'ব্যাকআপ ফাইল পড়া যায়নি';

  @override
  String get saveMember => 'সদস্য সংরক্ষণ';

  @override
  String get updateMember => 'সদস্য আপডেট';

  @override
  String get myTotalPaid => 'আমার মোট জমা';

  @override
  String get cooperativeSummary => 'সমিতির সারাংশ';

  @override
  String get recentCooperativeDeposits => 'সমিতির সাম্প্রতিক ডিপোজিট';

  @override
  String get copyPhoneNumber => 'ফোন নম্বর কপি';

  @override
  String get phoneCopied => 'ফোন নম্বর কপি হয়েছে';

  @override
  String get changeProfilePhoto => 'প্রোফাইল ছবি পরিবর্তন';

  @override
  String get profilePhotoUpdated => 'প্রোফাইল ছবি আপডেট হয়েছে';

  @override
  String get canCollectDeposits => 'জমা সংগ্রহ করতে পারবে';

  @override
  String get canCollectDepositsHint =>
      'এই সদস্য অন্য সদস্যদের জমা রেকর্ড করতে পারবে';

  @override
  String get collectDeposit => 'জমা সংগ্রহ';

  @override
  String get signUpSubtitle => 'শুরু করতে আপনার সমবায় নিবন্ধন করুন';

  @override
  String get notifications => 'নটিফিকেশন';

  @override
  String get notificationsSubtitle => 'জমা ও স্মরণকারী';

  @override
  String get dueReminders => 'বকেয়া স্মরণ';

  @override
  String get dueRemindersSubtitle => 'প্রতি মাসের ১০ ও ২০ তারিখে স্মরণ';

  @override
  String get notificationDepositTitle => 'জমা রেকর্ড হয়েছে';

  @override
  String notificationDepositBody(int amount, int receipt) {
    return 'পরিমাণ: $amount টাকা · রসিদ #$receipt';
  }

  @override
  String get sendAnnouncement => 'ঘোষণা পাঠান';

  @override
  String get sendAnnouncementSubtitle =>
      'অ্যাপ খোলা থাকলে সদস্যরা নটিফিকেশন পাবে (Blaze লাগে না)';

  @override
  String get announcementTitle => 'শিরোনাম';

  @override
  String get announcementMessage => 'বার্তা';

  @override
  String get send => 'পাঠান';

  @override
  String announcementSent(int sent, int total) {
    return '$total জনের মধ্যে $sent জনকে পাঠানো হয়েছে';
  }

  @override
  String get announcementPublished =>
      'ঘোষণা প্রকাশিত। সদস্যরা অনলাইনে থাকলে নটিফিকেশন পাবে।';
}
