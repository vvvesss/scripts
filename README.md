# README

## GCE SSH Alias and Host Record Generator

This Perl script dynamically generates host records and SSH aliases from your Google Cloud Compute Engine (GCE) instance list. It allows you to easily SSH into your instances using their names instead of manually looking up their IP addresses.

---

## Requirements

- A Unix-like OS (Linux, FreeBSD, macOS, etc.)
- A working `gcloud` CLI with access to list instances
- Bash shell (or modify the script accordingly for other shells)

---

## How It Works

1. The script fetches the list of GCE instances and their internal IPs.
2. It updates `/etc/hosts` to map instance names to internal IPs.
3. It updates your shell profile (default: `~/.bash_profile`) with SSH aliases.
4. You can then SSH into your instances using their names instead of IP addresses.
5. If any changes occur (e.g., instance name or IP updates), running the script again updates the records automatically.

---

## Pre-Check

Before running the script, verify that the following command works and returns the expected list of instances:

```sh
 gcloud compute instances list --format="csv(NAME,ZONE,MACHINE_TYPE,PREEMPTIBLE,INTERNAL_IP,EXTERNAL_IP,STATUS)"
```

---

## Setup

### Step 1: Define SSH Function

Add this function to your bash profile (`~/.bash_profile` or `~/.bashrc`):

```sh
sg () {
  ip=${1}
  ssh <your_gcp_user>@$ip
}
```

Replace `<your_gcp_user>` with your actual GCP username.

### Step 2: Run the Script

Execute the Perl script:

```sh
perl gce_ssh_aliases.pl
```

### Step 3: Reload Your Profile

After running the script, reload your shell profile:

```sh
source ~/.bash_profile  # Or your respective profile file
```

---

## Usage

Once the script has been executed and your profile reloaded, you can SSH into your instances using their names:

```sh
sg instance-name
```

or simply:

```sh
ssh instance-name
```

---

## Notes

- If the script detects changes in instance names or IPs, it will update `/etc/hosts` and your shell profile automatically.
- Ensure that you have appropriate permissions to modify `/etc/hosts`.
- Modify `$profile` in the script if using a different shell profile file.

---

## Troubleshooting

- If SSH does not work, verify that `gcloud` is properly configured and that the script successfully updated your `/etc/hosts` and profile.
- If necessary, run the script again to update any changes in the GCE instance list.
- Check permissions if the script fails to write to `/etc/hosts` or your profile.

---

## License

This script is provided as-is with no warranty. Modify and use at your own risk.

