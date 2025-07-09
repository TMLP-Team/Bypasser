# Bypasser

This is a developing Magisk module for bypassing Android environment detection related to TMLP. The abbreviation "TMLP" stands for anything related to TWRP, Magisk, LSPosed, and Plugins. 

This module will only take effect when users install it or click the ``action`` button. The current supported features are as follows. 

- Welcome (0b00000X): Perform built-in configurations for this module. 
- Zygisk Traces (0b0000X0): Deploy correct configurations for different Zygisk solutions according to the Zygisk implementation, Shamiko, NoHello, and Zygisk Assistant modules used. 
- HMA(L) (0b000X00): Generate HMA(L) configurations based on cloud libraries (along with the web UI updating) and local packages. Users are required to manually import the configurations via HMA(L). Networks to GitHub are optional. 
- Tricky Store (0b00X000): Generate Tricky Store configurations directly based on cloud libraries and local packages. The configurations will be written to the Tricky Store configuration folder directly. Networks to GitHub are optional. 
- Shell (0b0X0000): Perform some shell commands. Please check ``actionA.sh`` for details. 
  - Disable sensitive applications automatically installed by Google. 
  - Remove sensitive policies. 
  - Handle properties. 
  - Check the existence of applications in Classifications $B$ and $C$ as a non-root user. 
  - Check whether the system release version has been banned. 
  - Patch ``/etc/compatconfig/services-platform-compat-config.xml``
  - Enable the feature of hiding desktop icons on devices running Android 10 or above. 
- Update (0bX00000): Perform regular dynamic updates for ``action.sh`` and the web UI (processed in the HMA(L) stage). Networks to GitHub are required. 

Please kindly be aware that this module will only optimize the rooting and injection environments based on the current environments. It will not include, install, disable, or uninstall any other modules or plugins. 
The implementation and bypassing of these environments should be challenging and complex procedures. Users should learn related knowledge before taking these actions. 
Relying on one-key solutions or paying others for remote deployment without knowing the principles is incorrect. 

## Compilation

If you want to build the module for testing purposes on your own, please use ``git clone`` to clone this repository to your local device.

Execute ``./build.sh`` in the root folder of the local repository after you check carefully and grant suitable execution permissions. 

Submit modifications via a pull request (PR) if you wish to. 

## Acknowledgement

Here, we express our sincere gratitude to [@pumPCin](https://github.com/pumPCin) for providing old HMA(L) configuration folders in [https://github.com/pumPCin/HMAL/issues/50](https://github.com/pumPCin/HMAL/issues/50). 

## Licensing

This project is under the ``GPL-3.0`` license. You can also regard this project as a Magisk module template or a template GitHub repository for Magisk module development. The A/B architecture is implemented for the dynamic updating of ``action``. 

## Warning

Since the project is still developing, please do not install the module here until this warning is removed in the future. 
