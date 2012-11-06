UniversalMailer
===============

Universal Mailer plugin for Mail.app

Universal Mailer is a Mail.app plugin that solves some issues when sending emails. It removes ATT00001.htm files,
   it correctly formats messages with attachments and inline images and offers an option to set the default font for outgoing messages.
   </p>
   <p>
   When enabled, Universal Mailer is able to correctly format outgoing emails, so that even after Exchange EWS
   filtering they retain the original format.
   </p>
   <p>
   The plugin runs in the background without interfering with your work: all you have to do is set a default font for outgoing emails and
   write your emails as usual. When you hit the Send button Universal Mailer checks the email for you and modifies it as needed.
   </p>

   <h3>Do I need it?</h3>
   <p>Universal Mailer will be useful if any of these sound familiar to you:</p>
   <ul>
    <li>Your sent email contains unwanted ATT00001.htm attachments that prevent some email clients from viewing the complete text</li>
    <li>You are used to alternate text and images inside your emails but your recipients can't see them as intended</li>
    <li>Your sent emails are hard to read because they are displayed with a small font by some email clients</li>
   </ul>

<h3>License</h3>
<p>
This project is release under MIT license (see below), except for mimetic library which follows a GPLv2 license
(you can find the original copyright and disclaimer in mimetic source files).
</p>
<p>
   Copyright (C) 2012 noware
 
   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
   associated documentation files (the "Software"), to deal in the Software without restriction,
   including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
   and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:
  
   The above copyright notice and this permission notice shall be included in all copies or substantial
   portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
   AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

</p>

<h3>FAQ</h3>
   <p>When using the plugin you may encounter situations where it simply doesn't work. Below are a few common questions that may
   help you if you're in trouble.</p>

   <h4>Q: After I installed the plugin nothing happens. The plugin is not working</h4>
   <p>A: Check if you have other Mail.app plugins installed. Similar plugins may interfere with Universal Mailer and vice-versa. Consider removing
   all of them and keeping only the one you're using.
   It might also be that the installer failed to correctly install the plugin. You can try running the following commands in Terminal app (/Applications/Utilities), they might ask you for your login password:

<ul>
<li>defaults write com.apple.mail EnableBundles -bool YES</li>
<li>defaults write com.apple.mail BundleCompatibilityVersion -int 3</li>
<li>sudo defaults write com.apple.mail EnableBundles -bool YES</li>
<li>sudo defaults write com.apple.mail BundleCompatibilityVersion -int 3</li>
</ul>
After this if you go to Mail.app's Preferences you should see a '>>' symbol on the top right, which discovers Universal Mailer preference panel.
</p>

   <h4>Q: I installed the plugin and I think it loads correctly. Why doesn't it do what it should?</h4>
   <p>A: Check if your Mail.app's settings match those listed on 'Installation &amp; Usage' section. Also, always include an HTML signature,
   as plain text email are _not_ checked by Universal Mailer.</p>

   <h4>Q: Now that I can change the font, what is the suggested size for a 'readable' email?</h4>
   <p>A: It largely depends on personal preference and what you mean by 'readable', however you could start with Helvetica 14pts.
   This is one of the standard fonts, the one you see by default in Mail.app.</p>

   <h4>Q: When I send an email the signature doesn't match Universal Mailer default font</h4>
   <p>A: Signatures (as well as other formatted texts) usually comes with a custom font or a custom size. Universal Mailer can't touch it, because
    it is outside its purposes. Doing so could prevent you to send email with different fonts and sizes.</p>

   <h4>Q: I updated OS X to the latest 10.X.Y version and the plugin has been disabled by Mail.app. What now?</h4>
   <p>A: Due to Apple's restrictions on Mail.app plugins this is a problem you have to live with. After an upgrade of the OS, Apple disables
    all third party's plugins, including Universal Mailer. You need a new version of the plugin to make it work again, it will be posted on the
    download page as soon as it is ready. Starting from version 1.4 you don't need to wait for a new version: just install it again and the
    plugin will be enabled again.</p>

   <h4>Q: I'm trying to install the plugin on Mountain Lion but the system tells me the software comes from an unidentified developer</h4>
   <p>A: This software is not signed, so you have to force the system to load it, in case it refuses to launch it. To temporary change the security policy and install the plugin go to System Preferences, select 'Security &amp; Privacy' and set 'Allow applications downloaded from' to 'Anywhere'. You can then launch the installer and once it completes switch back to your previous setting (Mac App Store or Mac App Store and identified developers).</p>

