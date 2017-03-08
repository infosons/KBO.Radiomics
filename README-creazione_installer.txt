Creazione installer per piattaforma Windows
===========================================
La creazione dell'installer di KBO.Radiomics e' totalmente automatizzata tramite lo script "SetupModernRadiomicaGUI.nsi" NSIS presente nella root del repository.

Lo script presuppone la seguente struttura dei file e delle directory:
	KBO.Radiomics/
	├── GoogleChromePortable/
	├── R-Portable/
	├── Shiny/
	├── license.rtf
	├── README-creazione_installer.txt
	├── runShinyApp.r
	├── run.vbs
	└── SetupModernRadiomicaGUI.nsi

Nel repository sono presenti le directory Shiny e R-Portable mentre Google Chrome Portable deve essere scaricato ed installato nella directory KBO.Radiomics in modo da rispettare la struttura di cui sopra.
Google Chrome Portable si scarica dal seguente link: http://downloads.sourceforge.net/portableapps/GoogleChromePortable_54.0.2840.71_online.paf.exe

Inoltre, per poter compilare lo script bisogna installare il Nullsoft Scriptable Install System	(http://prdownloads.sourceforge.net/nsis/nsis-3.0-setup.exe?download).

Una volta installato il Nullsoft Installer, l'installer KBO.Radiomics si genera con un clic destro sul file SetupModernRadiomicaGUI.nsi e scegliendo la voce "compila script".

Il risultante eseguibile avra' nome Setup_KBO.Radiomics-<versione>_<AAA.MM.GG-hhmmss>.exe e si trovera' nella stessa directory dello script.