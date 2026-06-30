// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cooperative Management';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get members => 'Members';

  @override
  String get due => 'Due';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get trash => 'Trash';

  @override
  String get addDeposit => 'Add Deposit';

  @override
  String get addMember => 'Add Member';

  @override
  String get editMember => 'Edit Member';

  @override
  String get memberDetails => 'Member Details';

  @override
  String get dueReport => 'Due Report';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get required => 'Required';

  @override
  String get search => 'Search';

  @override
  String get searchBy => 'Search by name / member id / phone';

  @override
  String get totalCollection => 'Total Collection';

  @override
  String get totalDue => 'Total Due';

  @override
  String get collection => 'Collection';

  @override
  String currentMonth(String month) {
    return 'Current Month ($month)';
  }

  @override
  String monthPaymentStatus(String month) {
    return 'Payment Status ($month)';
  }

  @override
  String get collectionByMonth => 'Collection by Month';

  @override
  String get noMembersYet => 'No members yet';

  @override
  String get noMembersFound => 'No members found';

  @override
  String get tapToAddFirstMember => 'Tap + to add your first member';

  @override
  String get addFirstMember => 'Add First Member';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get noDueMembers => 'No Due Members';

  @override
  String get allMembersUpToDate =>
      'All members are up to date with their payments! 🎉';

  @override
  String get noDue => 'No due';

  @override
  String get months => 'Months';

  @override
  String get memberIdNumber => 'Member ID Number';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get address => 'Address';

  @override
  String get addressOptional => 'Address (optional)';

  @override
  String get nidNumber => 'NID Number';

  @override
  String get nidNumberOptional => 'NID Number (optional)';

  @override
  String get monthlyAmount => 'Monthly Amount (BDT)';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get memberTypeNameOrId => 'Member (type name or ID)';

  @override
  String get memberCannotBeChanged => 'Member (cannot be changed)';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount (BDT)';

  @override
  String get fromMonth => 'From Month';

  @override
  String get toMonth => 'To Month';

  @override
  String get toMonthOptional => 'To Month (Optional)';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get selectMonthOptional => 'Select month (optional)';

  @override
  String get noneSingleMonth => 'None (Single Month)';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get bkash => 'bKash';

  @override
  String get nagad => 'Nagad';

  @override
  String get bank => 'Bank';

  @override
  String get receivedBy => 'Received By';

  @override
  String get confirmDeposit => 'Confirm Deposit';

  @override
  String depositAmount(String amount) {
    return 'Deposit amount: $amount';
  }

  @override
  String member(String name) {
    return 'Member: $name';
  }

  @override
  String get confirmGenerateReceipt =>
      'Do you want to confirm and generate receipt?';

  @override
  String get confirmGenerateReceiptButton => 'Confirm & Generate Receipt';

  @override
  String get depositConfirmed => 'Deposit confirmed. Receipt generated.';

  @override
  String get depositUpdated => 'Deposit updated successfully';

  @override
  String get error => 'Error';

  @override
  String get errorLoadingMember => 'Error loading member';

  @override
  String get errorLoadingMembers => 'Error loading members';

  @override
  String get invalidImagePath => 'Invalid image path';

  @override
  String get selectedImageNotFound => 'Selected image file not found';

  @override
  String errorCheckingFile(String error) {
    return 'Error checking file: $error';
  }

  @override
  String errorAccessingDirectory(String error) {
    return 'Error accessing directory: $error';
  }

  @override
  String errorCreatingFolder(String error) {
    return 'Error creating folder: $error';
  }

  @override
  String errorSavingImage(String error) {
    return 'Error saving image: $error';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get memberSaved => 'Member saved successfully';

  @override
  String get memberUpdated => 'Member updated successfully';

  @override
  String get deleteMember => 'Delete Member';

  @override
  String deleteMemberConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This will move the member to trash.';
  }

  @override
  String get memberDeleted => 'Member deleted successfully';

  @override
  String get memberRestored => 'Member restored successfully';

  @override
  String get memberPermanentlyDeleted => 'Member permanently deleted';

  @override
  String get depositDeleted => 'Deposit deleted successfully';

  @override
  String get depositRestored => 'Deposit restored successfully';

  @override
  String get depositPermanentlyDeleted => 'Deposit permanently deleted';

  @override
  String get failedToLoadOrganization => 'Failed to load organization';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get organizationNameAndAddress => 'Organization name and address';

  @override
  String get organizationName => 'Organization Name';

  @override
  String get enterOrganizationName => 'Enter organization name';

  @override
  String get organizationAddress => 'Organization Address';

  @override
  String get enterOrganizationAddress => 'Enter organization address';

  @override
  String get brandingIdentity => 'Branding & Identity';

  @override
  String get logoAndSignature => 'Logo and signature for documents';

  @override
  String get logo => 'Logo';

  @override
  String get usedInReceiptsAndReports => 'Used in receipts and reports';

  @override
  String get signature => 'Signature';

  @override
  String get receiptConfiguration => 'Receipt Configuration';

  @override
  String get receiptSettings => 'Receipt prefix and serial number settings';

  @override
  String get receiptPrefix => 'Receipt Prefix';

  @override
  String get defaultReceivedBy => 'Default Received By';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeAndLanguage => 'Theme mode and language settings';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get auto => 'Auto';

  @override
  String get language => 'Language';

  @override
  String get bengali => 'বাংলা';

  @override
  String get english => 'English';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get backupAndRestore => 'Backup and restore your data';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get saveAllSettings => 'Save All Settings';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get backupExported => 'Backup exported successfully';

  @override
  String get backupImported => 'Backup imported successfully';

  @override
  String errorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String get annualReport => 'Annual Report';

  @override
  String get yearWiseSummary => 'Year-wise collection summary';

  @override
  String get memberReport => 'Member Report';

  @override
  String get individualMemberDetails => 'Individual member details and reports';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get monthWiseCollection => 'Month-wise collection and member status';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get selectYear => 'Select Year';

  @override
  String get selectMember => 'Select Member';

  @override
  String get reportGenerated => 'Report generated successfully';

  @override
  String get reportExported => 'Report exported successfully';

  @override
  String get deletedMembers => 'Deleted Members';

  @override
  String get deletedDeposits => 'Deleted Deposits';

  @override
  String get restore => 'Restore';

  @override
  String get permanentDelete => 'Permanent Delete';

  @override
  String get emptyTrash => 'Empty Trash';

  @override
  String get emptyTrashConfirm =>
      'Are you sure you want to permanently delete all items in trash? This action cannot be undone.';

  @override
  String get trashEmptied => 'Trash emptied successfully';

  @override
  String get noDeletedMembers => 'No deleted members';

  @override
  String get noDeletedDeposits => 'No deleted deposits';

  @override
  String get memberId => 'Member ID';

  @override
  String phoneLabel(String phone) {
    return 'Phone: $phone';
  }

  @override
  String addressLabel(String address) {
    return 'Address: $address';
  }

  @override
  String nidLabel(String nid) {
    return 'NID: $nid';
  }

  @override
  String monthlyAmountLabel(String amount) {
    return 'Monthly Amount: $amount';
  }

  @override
  String get balanceSummary => 'Balance Summary';

  @override
  String get totalDeposited => 'Total Deposited';

  @override
  String get expectedTotal => 'Expected Total';

  @override
  String get netDueAdvance => 'Net Due/Advance';

  @override
  String get deposits => 'Deposits';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get all => 'All';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get selectEndDate => 'Select End Date';

  @override
  String get depositHistory => 'Deposit History';

  @override
  String get noDeposits => 'No deposits';

  @override
  String get receiptNumber => 'Receipt Number';

  @override
  String get method => 'Method';

  @override
  String get reason => 'Reason';

  @override
  String duplicateDepositError(String month) {
    return 'Deposit already exists for this month: $month. Multiple deposits for the same month are not allowed.';
  }

  @override
  String duplicateDepositsError(String months) {
    return 'Deposits already exist for these months: $months. Multiple deposits for the same month are not allowed.';
  }

  @override
  String get adminLogin => 'Admin';

  @override
  String get memberLogin => 'Member';

  @override
  String get loginWelcome => 'Welcome';

  @override
  String get loginSubtitleMember => 'Sign in with your organization short name';

  @override
  String get loginSubtitleAdmin => 'Sign in to manage your cooperative';

  @override
  String get loginSwitchToAdmin => 'Administrator login';

  @override
  String get loginSwitchToMember => 'Member login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pin => 'PIN';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get passwordLengthHint => 'Password must be at least 6 characters';

  @override
  String get defaultMemberPassword => 'Default Member Password';

  @override
  String get defaultMemberPasswordHint =>
      'Used when creating new member login accounts';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get myProfile => 'My Profile';

  @override
  String get myDue => 'My Due';

  @override
  String get initialPin => 'Initial PIN';

  @override
  String get resetPin => 'Reset PIN (optional)';

  @override
  String get resetPinHint => 'Leave blank to keep current PIN';

  @override
  String get phoneAlreadyUsed => 'This phone number is already registered';

  @override
  String get noDueAmount => 'No due amount. You are up to date.';

  @override
  String get errorLoadingData => 'Failed to load data';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signUpTitle => 'Register Cooperative';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'New cooperative? Sign Up';

  @override
  String get cooperativeAlreadyRegistered =>
      'A cooperative is already registered. Please login.';

  @override
  String get signUpFailed => 'Sign up failed. Please try again.';

  @override
  String get memberLoginHint =>
      'Use your phone number as username and the default password from admin.';

  @override
  String get signUpSuccess => 'Cooperative registered successfully';

  @override
  String get organizationShortName => 'Organization Short Name';

  @override
  String get organizationShortNameHint => 'e.g. SSF, BRAC';

  @override
  String get organizationShortNameHelper =>
      'Members type this on login (2–12 letters/numbers)';

  @override
  String get shortNameTaken => 'This short name is already taken';

  @override
  String get shortNameInvalid => 'Use 2–12 letters or numbers only';

  @override
  String get memberLoginShortName => 'Organization Short Name';

  @override
  String get memberLoginShortNameHint =>
      'Type your cooperative short name (e.g. SSF)';

  @override
  String get memberLoginConfirmOrg => 'Logging in to';

  @override
  String get memberLoginContinue => 'Continue';

  @override
  String get memberLoginChangeOrg => 'Change organization';

  @override
  String get memberShareShortName => 'Members type this short name on login';

  @override
  String get syncStatusSynced => 'Synced';

  @override
  String get syncStatusSyncing => 'Syncing…';

  @override
  String get syncStatusConnecting => 'Connecting…';

  @override
  String get syncStatusError => 'Sync error';

  @override
  String get syncStatusOffline => 'Offline';

  @override
  String get settingsTabOrganization => 'Organization';

  @override
  String get settingsTabReceipt => 'Receipt';

  @override
  String get settingsTabMemberApp => 'Member app';

  @override
  String get settingsTabSystem => 'System';

  @override
  String get setShortNameForLogin => 'Set a short name for member login';

  @override
  String get addLogo => 'Add Logo';

  @override
  String get removeLogo => 'Remove Logo';

  @override
  String get signatureOnReceipts => 'Appears at the bottom of receipts';

  @override
  String get tapAddSignature => 'Tap to add signature image';

  @override
  String get removeSignature => 'Remove Signature';

  @override
  String get memberDashboardSettings => 'Member Dashboard';

  @override
  String get memberDashboardSettingsSubtitle => 'What members can see';

  @override
  String get coopCurrentMonth => 'Cooperative current month';

  @override
  String get coopTotalCollection => 'Cooperative total collection';

  @override
  String get coopTotalDue => 'Cooperative total due';

  @override
  String get membersWithDueList => 'Members with due list';

  @override
  String get backupExportHint =>
      'Export all your data to a JSON file for backup. You can restore it later.';

  @override
  String get importBackupTitle => 'Import Backup';

  @override
  String get importBackupMessage =>
      'This will import data from the backup file. Existing data with the same UUID will be merged. Continue?';

  @override
  String get import => 'Import';

  @override
  String get couldNotReadBackup => 'Could not read backup file';

  @override
  String get saveMember => 'Save Member';

  @override
  String get updateMember => 'Update Member';

  @override
  String get myTotalPaid => 'My Total Paid';

  @override
  String get cooperativeSummary => 'Cooperative Summary';

  @override
  String get recentCooperativeDeposits => 'Recent Cooperative Deposits';

  @override
  String get copyPhoneNumber => 'Copy Phone Number';

  @override
  String get phoneCopied => 'Phone number copied';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String get canCollectDeposits => 'Can collect deposits';

  @override
  String get canCollectDepositsHint =>
      'Allow this member to record deposits for others';

  @override
  String get collectDeposit => 'Collect Deposit';

  @override
  String get signUpSubtitle => 'Register your cooperative to get started';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Deposits and reminders';

  @override
  String get dueReminders => 'Due reminders';

  @override
  String get dueRemindersSubtitle =>
      'Remind on the 10th and 20th of each month';

  @override
  String get notificationDepositTitle => 'Deposit recorded';

  @override
  String notificationDepositBody(int amount, int receipt) {
    return 'Amount: $amount BDT · Receipt #$receipt';
  }

  @override
  String get sendAnnouncement => 'Send Announcement';

  @override
  String get sendAnnouncementSubtitle =>
      'Members get a notification when the app is open (no Blaze plan needed)';

  @override
  String get announcementTitle => 'Title';

  @override
  String get announcementMessage => 'Message';

  @override
  String get send => 'Send';

  @override
  String announcementSent(int sent, int total) {
    return 'Sent to $sent of $total members';
  }

  @override
  String get announcementPublished =>
      'Announcement published. Members will be notified when online.';
}
