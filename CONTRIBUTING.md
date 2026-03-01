# 🤝 Contributing to Azure Migrate & Arc Workshop

Thank you for your interest in contributing to the **Azure Migrate & Arc Workshop** by Haris Khurshid, MCT!

---

## 📋 How to Contribute

### 1. Report Bugs
- Use the [Bug Report](../../issues/new?template=bug_report.md) template
- Include deployment logs, screenshots, and steps to reproduce

### 2. Suggest Features
- Use the [Feature Request](../../issues/new?template=feature_request.md) template
- Describe the use case and expected behavior

### 3. Submit Changes
1. **Fork** this repository
2. Create a **feature branch**: `git checkout -b feature/your-feature-name`
3. **Make changes** and test them
4. **Commit** with clear messages: `git commit -m "Add: description of change"`
5. **Push** to your fork: `git push origin feature/your-feature-name`
6. Open a **Pull Request** against `main`

---

## 📝 Commit Message Convention

Use these prefixes:

| Prefix | Usage |
|--------|-------|
| `Add:` | New feature, file, or module |
| `Fix:` | Bug fix |
| `Update:` | Changes to existing content |
| `Docs:` | Documentation only changes |
| `Refactor:` | Restructuring without changing behavior |

**Examples:**
```
Add: Module 05 for Azure Sentinel integration
Fix: BootstrapLabHost.ps1 7-Zip extraction path
Update: ARM template VM size options
Docs: Troubleshooting guide for DHCP issues
```

---

## 🔧 Development Guidelines

### ARM Templates
- Validate with `az deployment group validate` before submitting
- Use parameter defaults where sensible
- Include descriptive metadata on all parameters
- Tag all resources consistently

### PowerShell Scripts
- Include comment-based help at the top of each script
- Use `Write-Host` with `-ForegroundColor` for status output
- Include error handling with `try/catch` blocks
- Log output with `Start-Transcript`

### Documentation
- Use Markdown with proper headings (H1 for title, H2 for sections)
- Include step-by-step instructions with screenshots where helpful
- Reference VM names, IPs, and credentials from the main README
- Link back to relevant modules

### Workshop Modules
- Follow the existing module structure (Overview, Prerequisites, Objectives, Exercises, Summary)
- Each exercise should have numbered steps
- Include expected output/results for verification
- Estimate time for each exercise

---

## 🏗️ Project Structure

```
azure-migrate-and-arc-workshop/
├── .github/ISSUE_TEMPLATE/     # Issue templates
├── deploy/                      # ARM templates
├── scripts/                     # PowerShell automation
├── docs/                        # Additional documentation
├── modules/                     # Workshop modules (00-04)
├── README.md                    # Main project README
├── LICENSE                      # MIT License
├── CONTRIBUTING.md              # This file
└── CHANGELOG.md                 # Version history
```

---

## 🧪 Testing Checklist

Before submitting a PR, verify:

- [ ] ARM template validates successfully
- [ ] PowerShell scripts run without errors
- [ ] All markdown renders correctly on GitHub
- [ ] Links between documents work
- [ ] VM names, IPs, and credentials are consistent
- [ ] No sensitive information is exposed

---

## 🌐 Lab Environment Reference

When contributing, use these consistent values:

| Item | Value |
|------|-------|
| Company | HarisKhurshidLTD |
| Domain | hariskhurshidltd.local |
| NetBIOS | HARISKLTD |
| Subnet | 192.168.100.0/24 |
| Gateway | 192.168.100.1 |
| DC IP | 192.168.100.10 |
| Web1 IP | 192.168.100.20 |
| Web2 IP | 192.168.100.21 |
| SQL1 IP | 192.168.100.30 |
| Linux1 IP | 192.168.100.40 |
| Storage | https://hariskhurshid.blob.core.windows.net/hariskhurshidltd |

---

## 📜 Code of Conduct

- Be respectful and constructive
- Focus on the technical content
- Help others learn — this is an educational project
- Credit original sources when applicable

---

## 📞 Questions?

Open an [issue](../../issues) or reach out to the maintainer:

**Haris Khurshid, MCT** — [GitHub Profile](https://github.com/hariskhurshid12111)

---

*Thank you for helping make this workshop better for everyone!* 🙏
