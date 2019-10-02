@snap[west]
<h3>Supercharging Your Productivity with <a href='https://github.com/scrthq/PSProfile/'>PSProfile</a></h3>
<hr>
<h4>Nate Ferrell<br><i>Sr. Systems & DevOps Engineer</i><br>AWS Certified Associate (<i>S.A., Dev, SysOps</i>)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[slack] @scrthq](https://aka.ms/PSSlack)</h5>
@snapend

---

### Summary

During this session, we'll cover...

@ul
- 🤔 What PSProfile is
- 💪 Goals of the module
- 🚀 Getting started with the Configuration Helper
- ✨ Converting existing `$profile` content
- ⚡ Using Power Tools to work FAST
- 🔌 Extending PSProfile with custom plugins
@ulend

---

### 🤔 What is PSProfile?

PSProfile is a module enabling easy PowerShell @css[text-code](`$profile`) management. It is built to be a single-pane-of-glass to your full @css[text-code](`$profile`) as well as providing some productivity boosting features.

---

### 💪Goals of the module

PSProfile is designed to...

---

#### Minimize actual @css[text-code](`$profile`) contents...

@snap[text-07]
Your @css[text-code](`$profile`) can be reduced down to one line:<br/>@css[text-code](`Import-Module PSProfile`)
@snapend

---

#### Enable managing your @css[text-code](`$profile`) from a single location...

@snap[text-08]
Everything is stored on a single configuration file!
@snapend

---

#### Be portable...
@snap[text-08]
With `Export-PSProfileConfiguration` and `Export-PSProfileConfiguration`, migrating your `$profile` from one machine to the next is a breeze.
@snapend

---

#### Be extensible...

@snap[text-08]
PSProfile includes support for custom plugins. Plugins can be designed as a simple script or a full module and installed from the PowerShell Gallery or local file path.
@snapend

---

#### Provide quality-of-life improvements

@snap[text-07]
PSProfile includes a number of functions built with PowerShell development in mind:
@ul
- Project folder aliasing and argument completion
    - Quickly move between your Git repo folders by name with Git project tab-completion
- `Open-Code`
    - Designed to wrap the `code` CLI and provide additional functionality.
- `Start-BuildScript` (a.k.a. `bld`)
    - Easily launch a `build.ps1` script from anywhere in a sub-process.
- `Enter-CleanEnvironment` (a.k.a. `cln`)
    - Opens a clean child process with `-NoProfile` and some `PSReadline` settings added for convenience.
@ulend
@snapend

---

### Getting Started

---

#### Available Help

---

@snap[north-west span-50]
✔️ Comment-based help on all functions
@snapend
@snap[north-east span-50]
![Get-Help Get-Definition -Full](assets/img/Get-Help_Get-Definition.png)
@snapend

@snap[west span-50]
✔️ HelpFiles for each PSProfile Concept
@snapend
@snap[east span-50]
![Get-Help about_PSProfile*](assets/img/ConceptualHelpFiles.png)
@snapend

---

#### `Start-PSProfileConfigurationHelper`

![Start-PSProfileConfigurationHelper](assets/img/Start-PSProfileConfigurationHelper.png)

---

`Code time!`

---

### Converting existing `$profile` content

---

`Code time!`

---

### Using

---

### Conclusion

During this session, we covered...

@ul
- 🤔 What PSProfile is
- 💪 Goals of the module
- 🚀 Getting started
- ✨ Converting existing `$profile` content
- ⚡ Using Power Tools to work FAST
- 🔌 Extending PSProfile with custom plugins
@ulend

---

@snap[west]
<h3>Thank you for your time!</h3>
<hr>
<h4>Nate Ferrell<br><i>Sr. Systems & DevOps Engineer</i><br>AWS Certified Associate (<i>S.A., Dev, SysOps</i>)</h4>
<h5>[@fa[pencil] ferrell.io](https://ferrell.io/)<br>[@fa[github] @scrthq](https://github.com/scrthq)<br>[@fa[twitter] @scrthq](https://twitter.com/scrthq)<br>[@fa[slack] @scrthq](https://aka.ms/PSSlack)</h5>
@snapend
