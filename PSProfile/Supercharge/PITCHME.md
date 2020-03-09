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
✔️ Wiki on the GitHub Repository
@snapend
@snap[north-east span-40 fragment]
![PSProfile Wiki](assets/img/WikiHelp.png)
@snapend

@snap[west span-50 fragment]
✔️ HelpFiles for each PSProfile Concept
@snapend
@snap[east span-50 fragment]
![Get-Help about_PSProfile*](assets/img/ConceptualHelpFiles.png)
@snapend

@snap[south-west span-50 fragment]
✔️ Comment-based help on all functions
@snapend
@snap[south-east span-40 fragment]
![Get-Help Get-Definition -Full](assets/img/Get-Help_Get-Definition.png)
@snapend

---

#### The Configuration Helper

![Start-PSProfileConfigurationHelper](assets/img/Start-PSProfileConfigurationHelper.png)

---

PSProfile includes a Configuration Helper function to assist with getting started quickly:

@css[fragment](`Start-PSProfileConfigurationHelper`)

@css[fragment](Walking through the Configuration Helper during your first time using PSProfile is recommended, as it explains what each concept is about and provides the opportunity to add some base configurations.)

---

Let's step through the Configuration Helper...

@css[fragment](`Code time!`)

---

### Converting existing `$profile` content

---

PSProfile supports a wide range of common `$profile` items:

@ul
- Module importing
- Invoking external script files
- Command alias setting
- Custom prompt loading
- Environment and Global variable setting
@ulend

---

PSProfile also includes some bonus features that help with ensuring that your machine is configured the way you want:

@ul
- Missing module installation
- Symbolic Link creation
- Prompt management
@ulend

---

Let's walk through some existing `$profile` items and how you can add them to your PSProfile...

@css[fragment](`Code time!`)

---

### Using Power Tools to work FAST

PSProfile comes with a number of functions that are focused entirely on improving productivity and overall quality of life when working in the console...

---

@snap[north-west]
-  1/2
@snapend

@ul
- `Confirm-ScriptIsValid`
- `Enter-CleanEnvironment`
- `Format-Syntax`
- `Get-Definition`
- `Get-Gist`
- `Get-LongPath`
- `Install-LatestModule`
@ulend

---

@snap[north-west]
-  2/2
@snapend

@ul
- `Open-Code`
- `Open-Item`
- `Pop-Path`
- `Push-Path`
- `Start-BuildScript`
- `Test-RegEx`
@ulend

---

Most of the Power Tool functions greatly benefit from having at least one `Project Path` in your PSProfile configuration.

A `Project Path` is simply a path to a folder where you have Git Repos underneath, e.g. `E:\Git`, in my case. When refreshing PSProfile, these paths are searched for the following items to store in your configuration:

@ul
- Git repo folders (by the presence of the `.git` directory)
- PowerShell `build.ps1` scripts
@ulend

---

### Extending PSProfile with custom plugins

---

#### PSProfile is built to be extensible.

It ships with a couple helpful plugins included that demonstrate some of the options that you have when writing your own:

@ul
- `PSProfile.ADCompleters`
- `PSProfile.GitAliases`
@ulend

---

#### PSProfile.GitAliases Usage

@code[powershell code-wrap](PSProfile/Scripts/GitAliases.ps1)

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
