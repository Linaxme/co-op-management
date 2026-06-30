import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Cooperative Management'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @addDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add Deposit'**
  String get addDeposit;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @memberDetails.
  ///
  /// In en, this message translates to:
  /// **'Member Details'**
  String get memberDetails;

  /// No description provided for @dueReport.
  ///
  /// In en, this message translates to:
  /// **'Due Report'**
  String get dueReport;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchBy.
  ///
  /// In en, this message translates to:
  /// **'Search by name / member id / phone'**
  String get searchBy;

  /// No description provided for @totalCollection.
  ///
  /// In en, this message translates to:
  /// **'Total Collection'**
  String get totalCollection;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month ({month})'**
  String currentMonth(String month);

  /// No description provided for @monthPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status ({month})'**
  String monthPaymentStatus(String month);

  /// No description provided for @collectionByMonth.
  ///
  /// In en, this message translates to:
  /// **'Collection by Month'**
  String get collectionByMonth;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersYet;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get noMembersFound;

  /// No description provided for @tapToAddFirstMember.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first member'**
  String get tapToAddFirstMember;

  /// No description provided for @addFirstMember.
  ///
  /// In en, this message translates to:
  /// **'Add First Member'**
  String get addFirstMember;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @noDueMembers.
  ///
  /// In en, this message translates to:
  /// **'No Due Members'**
  String get noDueMembers;

  /// No description provided for @allMembersUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All members are up to date with their payments! 🎉'**
  String get allMembersUpToDate;

  /// No description provided for @noDue.
  ///
  /// In en, this message translates to:
  /// **'No due'**
  String get noDue;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @memberIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Member ID Number'**
  String get memberIdNumber;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get addressOptional;

  /// No description provided for @nidNumber.
  ///
  /// In en, this message translates to:
  /// **'NID Number'**
  String get nidNumber;

  /// No description provided for @nidNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'NID Number (optional)'**
  String get nidNumberOptional;

  /// No description provided for @monthlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly Amount (BDT)'**
  String get monthlyAmount;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @memberTypeNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Member (type name or ID)'**
  String get memberTypeNameOrId;

  /// No description provided for @memberCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Member (cannot be changed)'**
  String get memberCannotBeChanged;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (BDT)'**
  String get amount;

  /// No description provided for @fromMonth.
  ///
  /// In en, this message translates to:
  /// **'From Month'**
  String get fromMonth;

  /// No description provided for @toMonth.
  ///
  /// In en, this message translates to:
  /// **'To Month'**
  String get toMonth;

  /// No description provided for @toMonthOptional.
  ///
  /// In en, this message translates to:
  /// **'To Month (Optional)'**
  String get toMonthOptional;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @selectMonthOptional.
  ///
  /// In en, this message translates to:
  /// **'Select month (optional)'**
  String get selectMonthOptional;

  /// No description provided for @noneSingleMonth.
  ///
  /// In en, this message translates to:
  /// **'None (Single Month)'**
  String get noneSingleMonth;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get bkash;

  /// No description provided for @nagad.
  ///
  /// In en, this message translates to:
  /// **'Nagad'**
  String get nagad;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @receivedBy.
  ///
  /// In en, this message translates to:
  /// **'Received By'**
  String get receivedBy;

  /// No description provided for @confirmDeposit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deposit'**
  String get confirmDeposit;

  /// No description provided for @depositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount: {amount}'**
  String depositAmount(String amount);

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member: {name}'**
  String member(String name);

  /// No description provided for @confirmGenerateReceipt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to confirm and generate receipt?'**
  String get confirmGenerateReceipt;

  /// No description provided for @confirmGenerateReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Generate Receipt'**
  String get confirmGenerateReceiptButton;

  /// No description provided for @depositConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Deposit confirmed. Receipt generated.'**
  String get depositConfirmed;

  /// No description provided for @depositUpdated.
  ///
  /// In en, this message translates to:
  /// **'Deposit updated successfully'**
  String get depositUpdated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingMember.
  ///
  /// In en, this message translates to:
  /// **'Error loading member'**
  String get errorLoadingMember;

  /// No description provided for @errorLoadingMembers.
  ///
  /// In en, this message translates to:
  /// **'Error loading members'**
  String get errorLoadingMembers;

  /// No description provided for @invalidImagePath.
  ///
  /// In en, this message translates to:
  /// **'Invalid image path'**
  String get invalidImagePath;

  /// No description provided for @selectedImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Selected image file not found'**
  String get selectedImageNotFound;

  /// No description provided for @errorCheckingFile.
  ///
  /// In en, this message translates to:
  /// **'Error checking file: {error}'**
  String errorCheckingFile(String error);

  /// No description provided for @errorAccessingDirectory.
  ///
  /// In en, this message translates to:
  /// **'Error accessing directory: {error}'**
  String errorAccessingDirectory(String error);

  /// No description provided for @errorCreatingFolder.
  ///
  /// In en, this message translates to:
  /// **'Error creating folder: {error}'**
  String errorCreatingFolder(String error);

  /// No description provided for @errorSavingImage.
  ///
  /// In en, this message translates to:
  /// **'Error saving image: {error}'**
  String errorSavingImage(String error);

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @memberSaved.
  ///
  /// In en, this message translates to:
  /// **'Member saved successfully'**
  String get memberSaved;

  /// No description provided for @memberUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member updated successfully'**
  String get memberUpdated;

  /// No description provided for @deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMember;

  /// No description provided for @deleteMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This will move the member to trash.'**
  String deleteMemberConfirm(String name);

  /// No description provided for @memberDeleted.
  ///
  /// In en, this message translates to:
  /// **'Member deleted successfully'**
  String get memberDeleted;

  /// No description provided for @memberRestored.
  ///
  /// In en, this message translates to:
  /// **'Member restored successfully'**
  String get memberRestored;

  /// No description provided for @memberPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Member permanently deleted'**
  String get memberPermanentlyDeleted;

  /// No description provided for @depositDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deposit deleted successfully'**
  String get depositDeleted;

  /// No description provided for @depositRestored.
  ///
  /// In en, this message translates to:
  /// **'Deposit restored successfully'**
  String get depositRestored;

  /// No description provided for @depositPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deposit permanently deleted'**
  String get depositPermanentlyDeleted;

  /// No description provided for @failedToLoadOrganization.
  ///
  /// In en, this message translates to:
  /// **'Failed to load organization'**
  String get failedToLoadOrganization;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @organizationNameAndAddress.
  ///
  /// In en, this message translates to:
  /// **'Organization name and address'**
  String get organizationNameAndAddress;

  /// No description provided for @organizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get organizationName;

  /// No description provided for @enterOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Enter organization name'**
  String get enterOrganizationName;

  /// No description provided for @organizationAddress.
  ///
  /// In en, this message translates to:
  /// **'Organization Address'**
  String get organizationAddress;

  /// No description provided for @enterOrganizationAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter organization address'**
  String get enterOrganizationAddress;

  /// No description provided for @brandingIdentity.
  ///
  /// In en, this message translates to:
  /// **'Branding & Identity'**
  String get brandingIdentity;

  /// No description provided for @logoAndSignature.
  ///
  /// In en, this message translates to:
  /// **'Logo and signature for documents'**
  String get logoAndSignature;

  /// No description provided for @logo.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logo;

  /// No description provided for @usedInReceiptsAndReports.
  ///
  /// In en, this message translates to:
  /// **'Used in receipts and reports'**
  String get usedInReceiptsAndReports;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @receiptConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Receipt Configuration'**
  String get receiptConfiguration;

  /// No description provided for @receiptSettings.
  ///
  /// In en, this message translates to:
  /// **'Receipt prefix and serial number settings'**
  String get receiptSettings;

  /// No description provided for @receiptPrefix.
  ///
  /// In en, this message translates to:
  /// **'Receipt Prefix'**
  String get receiptPrefix;

  /// No description provided for @defaultReceivedBy.
  ///
  /// In en, this message translates to:
  /// **'Default Received By'**
  String get defaultReceivedBy;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Theme mode and language settings'**
  String get themeAndLanguage;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bengali;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore your data'**
  String get backupAndRestore;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @saveAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Save All Settings'**
  String get saveAllSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExported;

  /// No description provided for @backupImported.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully'**
  String get backupImported;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @annualReport.
  ///
  /// In en, this message translates to:
  /// **'Annual Report'**
  String get annualReport;

  /// No description provided for @yearWiseSummary.
  ///
  /// In en, this message translates to:
  /// **'Year-wise collection summary'**
  String get yearWiseSummary;

  /// No description provided for @memberReport.
  ///
  /// In en, this message translates to:
  /// **'Member Report'**
  String get memberReport;

  /// No description provided for @individualMemberDetails.
  ///
  /// In en, this message translates to:
  /// **'Individual member details and reports'**
  String get individualMemberDetails;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @monthWiseCollection.
  ///
  /// In en, this message translates to:
  /// **'Month-wise collection and member status'**
  String get monthWiseCollection;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @selectMember.
  ///
  /// In en, this message translates to:
  /// **'Select Member'**
  String get selectMember;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get reportGenerated;

  /// No description provided for @reportExported.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get reportExported;

  /// No description provided for @deletedMembers.
  ///
  /// In en, this message translates to:
  /// **'Deleted Members'**
  String get deletedMembers;

  /// No description provided for @deletedDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deleted Deposits'**
  String get deletedDeposits;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @permanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete'**
  String get permanentDelete;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrash;

  /// No description provided for @emptyTrashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all items in trash? This action cannot be undone.'**
  String get emptyTrashConfirm;

  /// No description provided for @trashEmptied.
  ///
  /// In en, this message translates to:
  /// **'Trash emptied successfully'**
  String get trashEmptied;

  /// No description provided for @noDeletedMembers.
  ///
  /// In en, this message translates to:
  /// **'No deleted members'**
  String get noDeletedMembers;

  /// No description provided for @noDeletedDeposits.
  ///
  /// In en, this message translates to:
  /// **'No deleted deposits'**
  String get noDeletedDeposits;

  /// No description provided for @memberId.
  ///
  /// In en, this message translates to:
  /// **'Member ID'**
  String get memberId;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(String phone);

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String addressLabel(String address);

  /// No description provided for @nidLabel.
  ///
  /// In en, this message translates to:
  /// **'NID: {nid}'**
  String nidLabel(String nid);

  /// No description provided for @monthlyAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Amount: {amount}'**
  String monthlyAmountLabel(String amount);

  /// No description provided for @balanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Balance Summary'**
  String get balanceSummary;

  /// No description provided for @totalDeposited.
  ///
  /// In en, this message translates to:
  /// **'Total Deposited'**
  String get totalDeposited;

  /// No description provided for @expectedTotal.
  ///
  /// In en, this message translates to:
  /// **'Expected Total'**
  String get expectedTotal;

  /// No description provided for @netDueAdvance.
  ///
  /// In en, this message translates to:
  /// **'Net Due/Advance'**
  String get netDueAdvance;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @depositHistory.
  ///
  /// In en, this message translates to:
  /// **'Deposit History'**
  String get depositHistory;

  /// No description provided for @noDeposits.
  ///
  /// In en, this message translates to:
  /// **'No deposits'**
  String get noDeposits;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt Number'**
  String get receiptNumber;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @duplicateDepositError.
  ///
  /// In en, this message translates to:
  /// **'Deposit already exists for this month: {month}. Multiple deposits for the same month are not allowed.'**
  String duplicateDepositError(String month);

  /// No description provided for @duplicateDepositsError.
  ///
  /// In en, this message translates to:
  /// **'Deposits already exist for these months: {months}. Multiple deposits for the same month are not allowed.'**
  String duplicateDepositsError(String months);

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminLogin;

  /// No description provided for @memberLogin.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberLogin;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcome;

  /// No description provided for @loginSubtitleMember.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your organization short name'**
  String get loginSubtitleMember;

  /// No description provided for @loginSubtitleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your cooperative'**
  String get loginSubtitleAdmin;

  /// No description provided for @loginSwitchToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator login'**
  String get loginSwitchToAdmin;

  /// No description provided for @loginSwitchToMember.
  ///
  /// In en, this message translates to:
  /// **'Member login'**
  String get loginSwitchToMember;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @passwordLengthHint.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthHint;

  /// No description provided for @defaultMemberPassword.
  ///
  /// In en, this message translates to:
  /// **'Default Member Password'**
  String get defaultMemberPassword;

  /// No description provided for @defaultMemberPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Used when creating new member login accounts'**
  String get defaultMemberPasswordHint;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @myDue.
  ///
  /// In en, this message translates to:
  /// **'My Due'**
  String get myDue;

  /// No description provided for @initialPin.
  ///
  /// In en, this message translates to:
  /// **'Initial PIN'**
  String get initialPin;

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN (optional)'**
  String get resetPin;

  /// No description provided for @resetPinHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current PIN'**
  String get resetPinHint;

  /// No description provided for @phoneAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered'**
  String get phoneAlreadyUsed;

  /// No description provided for @noDueAmount.
  ///
  /// In en, this message translates to:
  /// **'No due amount. You are up to date.'**
  String get noDueAmount;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get errorLoadingData;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Cooperative'**
  String get signUpTitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'New cooperative? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @cooperativeAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'A cooperative is already registered. Please login.'**
  String get cooperativeAlreadyRegistered;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get signUpFailed;

  /// No description provided for @memberLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Use your phone number as username and the default password from admin.'**
  String get memberLoginHint;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cooperative registered successfully'**
  String get signUpSuccess;

  /// No description provided for @organizationShortName.
  ///
  /// In en, this message translates to:
  /// **'Organization Short Name'**
  String get organizationShortName;

  /// No description provided for @organizationShortNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SSF, BRAC'**
  String get organizationShortNameHint;

  /// No description provided for @organizationShortNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Members type this on login (2–12 letters/numbers)'**
  String get organizationShortNameHelper;

  /// No description provided for @shortNameTaken.
  ///
  /// In en, this message translates to:
  /// **'This short name is already taken'**
  String get shortNameTaken;

  /// No description provided for @shortNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 2–12 letters or numbers only'**
  String get shortNameInvalid;

  /// No description provided for @memberLoginShortName.
  ///
  /// In en, this message translates to:
  /// **'Organization Short Name'**
  String get memberLoginShortName;

  /// No description provided for @memberLoginShortNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type your cooperative short name (e.g. SSF)'**
  String get memberLoginShortNameHint;

  /// No description provided for @memberLoginConfirmOrg.
  ///
  /// In en, this message translates to:
  /// **'Logging in to'**
  String get memberLoginConfirmOrg;

  /// No description provided for @memberLoginContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get memberLoginContinue;

  /// No description provided for @memberLoginChangeOrg.
  ///
  /// In en, this message translates to:
  /// **'Change organization'**
  String get memberLoginChangeOrg;

  /// No description provided for @memberShareShortName.
  ///
  /// In en, this message translates to:
  /// **'Members type this short name on login'**
  String get memberShareShortName;

  /// No description provided for @syncStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get syncStatusConnecting;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get syncStatusError;

  /// No description provided for @syncStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncStatusOffline;

  /// No description provided for @settingsTabOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get settingsTabOrganization;

  /// No description provided for @settingsTabReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get settingsTabReceipt;

  /// No description provided for @settingsTabMemberApp.
  ///
  /// In en, this message translates to:
  /// **'Member app'**
  String get settingsTabMemberApp;

  /// No description provided for @settingsTabSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsTabSystem;

  /// No description provided for @setShortNameForLogin.
  ///
  /// In en, this message translates to:
  /// **'Set a short name for member login'**
  String get setShortNameForLogin;

  /// No description provided for @addLogo.
  ///
  /// In en, this message translates to:
  /// **'Add Logo'**
  String get addLogo;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove Logo'**
  String get removeLogo;

  /// No description provided for @signatureOnReceipts.
  ///
  /// In en, this message translates to:
  /// **'Appears at the bottom of receipts'**
  String get signatureOnReceipts;

  /// No description provided for @tapAddSignature.
  ///
  /// In en, this message translates to:
  /// **'Tap to add signature image'**
  String get tapAddSignature;

  /// No description provided for @removeSignature.
  ///
  /// In en, this message translates to:
  /// **'Remove Signature'**
  String get removeSignature;

  /// No description provided for @memberDashboardSettings.
  ///
  /// In en, this message translates to:
  /// **'Member Dashboard'**
  String get memberDashboardSettings;

  /// No description provided for @memberDashboardSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What members can see'**
  String get memberDashboardSettingsSubtitle;

  /// No description provided for @coopCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Cooperative current month'**
  String get coopCurrentMonth;

  /// No description provided for @coopTotalCollection.
  ///
  /// In en, this message translates to:
  /// **'Cooperative total collection'**
  String get coopTotalCollection;

  /// No description provided for @coopTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Cooperative total due'**
  String get coopTotalDue;

  /// No description provided for @membersWithDueList.
  ///
  /// In en, this message translates to:
  /// **'Members with due list'**
  String get membersWithDueList;

  /// No description provided for @backupExportHint.
  ///
  /// In en, this message translates to:
  /// **'Export all your data to a JSON file for backup. You can restore it later.'**
  String get backupExportHint;

  /// No description provided for @importBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackupTitle;

  /// No description provided for @importBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'This will import data from the backup file. Existing data with the same UUID will be merged. Continue?'**
  String get importBackupMessage;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @couldNotReadBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not read backup file'**
  String get couldNotReadBackup;

  /// No description provided for @saveMember.
  ///
  /// In en, this message translates to:
  /// **'Save Member'**
  String get saveMember;

  /// No description provided for @updateMember.
  ///
  /// In en, this message translates to:
  /// **'Update Member'**
  String get updateMember;

  /// No description provided for @myTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'My Total Paid'**
  String get myTotalPaid;

  /// No description provided for @cooperativeSummary.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Summary'**
  String get cooperativeSummary;

  /// No description provided for @recentCooperativeDeposits.
  ///
  /// In en, this message translates to:
  /// **'Recent Cooperative Deposits'**
  String get recentCooperativeDeposits;

  /// No description provided for @copyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy Phone Number'**
  String get copyPhoneNumber;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied'**
  String get phoneCopied;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @canCollectDeposits.
  ///
  /// In en, this message translates to:
  /// **'Can collect deposits'**
  String get canCollectDeposits;

  /// No description provided for @canCollectDepositsHint.
  ///
  /// In en, this message translates to:
  /// **'Allow this member to record deposits for others'**
  String get canCollectDepositsHint;

  /// No description provided for @collectDeposit.
  ///
  /// In en, this message translates to:
  /// **'Collect Deposit'**
  String get collectDeposit;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register your cooperative to get started'**
  String get signUpSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deposits and reminders'**
  String get notificationsSubtitle;

  /// No description provided for @dueReminders.
  ///
  /// In en, this message translates to:
  /// **'Due reminders'**
  String get dueReminders;

  /// No description provided for @dueRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remind on the 10th and 20th of each month'**
  String get dueRemindersSubtitle;

  /// No description provided for @notificationDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit recorded'**
  String get notificationDepositTitle;

  /// No description provided for @notificationDepositBody.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} BDT · Receipt #{receipt}'**
  String notificationDepositBody(int amount, int receipt);

  /// No description provided for @sendAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Send Announcement'**
  String get sendAnnouncement;

  /// No description provided for @sendAnnouncementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members get a notification when the app is open (no Blaze plan needed)'**
  String get sendAnnouncementSubtitle;

  /// No description provided for @announcementTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get announcementTitle;

  /// No description provided for @announcementMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get announcementMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @announcementSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to {sent} of {total} members'**
  String announcementSent(int sent, int total);

  /// No description provided for @announcementPublished.
  ///
  /// In en, this message translates to:
  /// **'Announcement published. Members will be notified when online.'**
  String get announcementPublished;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
