/* eslint-disable max-len */
const {Resend} = require("resend");

// Lazily initialized so process.env is read at call time, not module load
let _resend = null;
const getResend = () => {
  if (!_resend) _resend = new Resend(process.env.RESEND_API_KEY);
  return _resend;
};

const year = new Date().getFullYear();

const buildWelcomeHtml = (name) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Welcome to Ikimina</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="margin:0;padding:0;background-color:#ffffff;font-family:'Sora',Arial,sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;">

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table role="presentation" width="560" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;width:100%;">

          <!-- LOGO -->
          <tr>
            <td style="padding-bottom:40px;">
              <span style="font-family:'Sora',Arial,sans-serif;font-size:22px;font-weight:800;letter-spacing:0.5px;">
                <span style="color:#1A1A1A;">Ikimina</span>
              </span>
              <br/>
              <span style="font-family:'Sora',Arial,sans-serif;font-size:10px;font-weight:400;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;">Smart Group Savings</span>
            </td>
          </tr>

          <!-- GREETING -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:15px;color:#111111;padding-bottom:12px;font-weight:500;">
              Hello ${name},
            </td>
          </tr>

          <!-- INTRO -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:15px;color:#111111;line-height:1.7;padding-bottom:28px;">
              Welcome to <strong>Ikimina</strong>. Your account has been created successfully.
              You can now create or join savings groups, track contributions, and manage
              withdrawals — all in one place.
            </td>
          </tr>

          <!-- ACCOUNT INFO BOX -->
          <tr>
            <td style="padding-bottom:28px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="background:#f5f5f3;padding:28px 24px;">
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:10px;font-weight:600;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;padding-bottom:16px;">
                          Account Details
                        </td>
                      </tr>

                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:12px;color:#888888;font-weight:400;padding-bottom:4px;">Full Name</td>
                      </tr>
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:20px;font-weight:700;color:#1A1A1A;letter-spacing:-0.3px;padding-bottom:20px;">
                          ${name}
                        </td>
                      </tr>

                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:12px;color:#888888;font-weight:400;padding-bottom:4px;">What you can do</td>
                      </tr>
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:14px;font-weight:500;color:#333333;line-height:1.8;padding-bottom:20px;">
                          &nbsp; Create or join a savings group<br/>
                          &nbsp; Track contributions in real time<br/>
                          &nbsp; Request withdrawals anytime
                        </td>
                      </tr>

                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:12px;color:#888888;font-weight:400;padding-bottom:4px;">Member since</td>
                      </tr>
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:14px;font-weight:600;color:#111111;">
                          ${new Date().toLocaleDateString("en-US", {year: "numeric", month: "long", day: "numeric"})}
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- NOTICE -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:14px;color:#555555;line-height:1.7;padding-bottom:36px;">
              Open the Ikimina app to get started. If you did not create this account,
              you can safely ignore this email.
            </td>
          </tr>

          <!-- DIVIDER -->
          <tr>
            <td style="padding-bottom:20px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="border-top:1px solid #e0e0db;font-size:0;line-height:0;">&nbsp;</td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:13px;padding-bottom:40px;">
              <span style="color:#1A1A1A;font-weight:700;letter-spacing:0.5px;">Ikimina</span>
              <span style="color:#aaaaaa;"> &copy; ${year} &mdash; Smart Group Savings</span>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>

</body>
</html>`;

/**
 * Sends a welcome email to a newly registered user.
 * @param {string} name  - User display name
 * @param {string} email - User email address
 * @return {Promise<object>} Resend response data
 */
const sendWelcomeEmail = async (name, email) => {
  const {data, error} = await getResend().emails.send({
    from: "Ikimina <noreply@ikimina.app>",
    to: [email],
    subject: "Welcome to Ikimina 🎉",
    html: buildWelcomeHtml(name),
  });

  if (error) throw new Error(`Resend error: ${error.message}`);
  return data;
};

/**
 * Sends an OTP verification email.
 * @param {string} name  - User display name
 * @param {string} email - User email address
 * @param {string} otp   - 6-digit OTP code
 * @return {Promise<object>} Resend response data
 */
const sendOtpEmail = async (name, email, otp) => {
  const {data, error} = await getResend().emails.send({
    from: "Ikimina <noreply@ikimina.app>",
    to: [email],
    subject: "Your Ikimina verification code",
    html: buildOtpHtml(name, otp),
  });

  if (error) throw new Error(`Resend error: ${error.message}`);
  return data;
};

const buildOtpHtml = (name, otp) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Verify your Ikimina account</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body style="margin:0;padding:0;background-color:#ffffff;font-family:'Sora',Arial,sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;">

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#ffffff;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table role="presentation" width="560" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;width:100%;">

          <!-- LOGO -->
          <tr>
            <td style="padding-bottom:40px;">
              <span style="font-family:'Sora',Arial,sans-serif;font-size:22px;font-weight:800;letter-spacing:0.5px;">
                <span style="color:#1A1A1A;">Ikimina</span>
              </span>
              <br/>
              <span style="font-family:'Sora',Arial,sans-serif;font-size:10px;font-weight:400;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;">Smart Group Savings</span>
            </td>
          </tr>

          <!-- GREETING -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:15px;color:#111111;padding-bottom:12px;font-weight:500;">
              Hello ${name},
            </td>
          </tr>

          <!-- INSTRUCTION -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:15px;color:#111111;line-height:1.7;padding-bottom:28px;">
              Use the verification code below to confirm your email address and activate your Ikimina account.
            </td>
          </tr>

          <!-- OTP BOX -->
          <tr>
            <td style="padding-bottom:28px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="background:#f5f5f3;padding:32px 24px;">
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:10px;font-weight:600;letter-spacing:3px;color:#aaaaaa;text-transform:uppercase;padding-bottom:16px;">
                          Verification Code
                        </td>
                      </tr>
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:11px;color:#888888;font-weight:400;padding-bottom:12px;">
                          Enter this code in the Ikimina app
                        </td>
                      </tr>
                      <!-- The OTP digits -->
                      <tr>
                        <td style="padding-bottom:20px;">
                          <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                            <tr>
                              ${otp.split("").map((d) => `
                              <td style="padding-right:8px;">
                                <div style="width:44px;height:52px;background:#ffffff;border:2px solid #e0e0db;text-align:center;line-height:52px;font-family:'Sora',Arial,sans-serif;font-size:24px;font-weight:800;color:#1A1A1A;letter-spacing:0;">
                                  ${d}
                                </div>
                              </td>`).join("")}
                            </tr>
                          </table>
                        </td>
                      </tr>
                      <tr>
                        <td style="font-family:'Sora',Arial,sans-serif;font-size:12px;color:#888888;font-weight:400;">
                          &#9203;&nbsp; This code expires in <strong style="color:#111111;">15 minutes</strong>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- NOTICE -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:14px;color:#555555;line-height:1.7;padding-bottom:36px;">
              If you did not request this code, you can safely ignore this email.
              Do not share this code with anyone.
            </td>
          </tr>

          <!-- DIVIDER -->
          <tr>
            <td style="padding-bottom:20px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="border-top:1px solid #e0e0db;font-size:0;line-height:0;">&nbsp;</td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="font-family:'Sora',Arial,sans-serif;font-size:13px;padding-bottom:40px;">
              <span style="color:#1A1A1A;font-weight:700;letter-spacing:0.5px;">Ikimina</span>
              <span style="color:#aaaaaa;"> &copy; ${year} &mdash; Smart Group Savings</span>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>

</body>
</html>`;

module.exports = {sendWelcomeEmail, sendOtpEmail};
