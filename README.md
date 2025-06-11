# Bypasser

This is a developing Magisk module for bypassing Android environment detection related to TMLP. The abbreviation "TMLP" stands for anything related to TWRP, Magisk, LSPosed, and Plugins. 

- Welcome (0b00000X): Perform built-in configurations for this module. 
- HMA/HMAL (0b0000X0): Generate HMA/HMAL configurations based on cloud libraries (along with the web UI updating) and local packages. Users are required to manually import the configurations via HMA/HMAL. Networks to GitHub are optional. 
- Tricky Store (0b000X00): Generate Tricky Store configurations directly based on cloud libraries and local packages. The configurations will be written to the Tricky Store configuration folder directly. Networks to GitHub are optional. 
- Zygisk Traces (0b00X000): Enforce denylist if ``Zygisk Next`` is used and make Shamiko work in the whitelist mode. 
- Shell (0b0X0000): Perform some shell commands. Please check ``actionA.sh`` for details. 
- Update (0bX00000): Perform regular dynamic updates for ``action.sh`` and the web UI (processed in the HMA/HMAL stage). Networks to GitHub are required. 

## Compilation

If you want to build the module for testing purposes on your own, please use ``git clone`` to clone this repository to your local device.

Execute ``./build.sh`` in the root folder of the local repository after you check carefully and grant suitable execution permissions. 

Submit modifications via a pull request (PR) if you wish to. 

## Acknowledgement

Here, we express our sincere gratitude to [@pumPCin](https://github.com/pumPCin) for providing old HMAL/HMA configuration folders in [https://github.com/pumPCin/HMAL/issues/50](https://github.com/pumPCin/HMAL/issues/50). 

## Licensing

This project is under the ``GPL-3.0`` license. You can also regard this project as a Magisk module template or a template GitHub repository for Magisk module development. 

## Warning

Since the project is still developing, please do not install the module here until this warning is removed in the future. 
