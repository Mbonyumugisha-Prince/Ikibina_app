import re

def update_strings():
    with open('lib/l10n/app_strings.dart', 'r') as f:
        text = f.read()

    props1 = """  // Profile Additions
  String get wallet;
  String get account;
  String get profileInformation;
  String get nameEmailPhone;
  String get kycVerification;
  String get approved;
  String get denied;
  String get verifiedMember;
  String get securityAndFinance;
  String get securityAnd2FA;
  String get paymentMethods;
  String get preferences;
  String get notifications;
  String get support;
  String get penalties;
  String get contactUs;
}"""
    text = text.replace('  String get back;\n}', '  String get back;\n\n' + props1)

    props2 = """  // Profile Additions
  @override String get wallet => 'Wallet';
  @override String get account => 'Account';
  @override String get profileInformation => 'Profile Information';
  @override String get nameEmailPhone => 'Name, Email, Phone number';
  @override String get kycVerification => 'KYC Verification';
  @override String get approved => 'Approved';
  @override String get denied => 'Denied';
  @override String get verifiedMember => 'Verified member';
  @override String get securityAndFinance => 'Security & Finance';
  @override String get securityAnd2FA => 'Security & 2FA';
  @override String get paymentMethods => 'Payment Methods';
  @override String get preferences => 'Preferences';
  @override String get notifications => 'Notifications';
  @override String get support => 'Support';
  @override String get penalties => 'Penalties';
  @override String get contactUs => 'Contact Us';
}"""
    text = text.replace("  @override String get fieldRequired      => 'This field is required';\n}", "  @override String get fieldRequired      => 'This field is required';\n\n" + props2)

    props3 = """  // Profile Additions
  @override String get wallet => 'Agakapu';
  @override String get account => 'Konti';
  @override String get profileInformation => 'Ibyerekeye Umwirondoro';
  @override String get nameEmailPhone => 'Amazina, Imeyili, Terefoni';
  @override String get kycVerification => 'Igenzura rya KYC';
  @override String get approved => 'Yemejwe';
  @override String get denied => 'Yanzwe';
  @override String get verifiedMember => 'Umunyamuryango Wemewe';
  @override String get securityAndFinance => 'Umutekano & Imari';
  @override String get securityAnd2FA => 'Umutekano & 2FA';
  @override String get paymentMethods => 'Uburyo bwo Kwishyura';
  @override String get preferences => 'Ibyo Ukeneye';
  @override String get notifications => 'Amakuru';
  @override String get support => 'Ubufasha';
  @override String get penalties => 'Ibihano';
  @override String get contactUs => 'Twandikire';
}"""
    text = text.replace("  @override String get fieldRequired      => 'Ibyo bipamba bikenewe';\n}", "  @override String get fieldRequired      => 'Ibyo bipamba bikenewe';\n\n" + props3)

    return text

if __name__ == '__main__':
    new_text = update_strings()
    with open('lib/l10n/app_strings.dart', 'w') as f:
        f.write(new_text)
