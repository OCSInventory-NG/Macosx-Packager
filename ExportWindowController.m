////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
// OCSINVENTORY-NG                                                                //
//                                                                                //
// Copyleft Guillaume PROTET 2012                                                 //
// Web : http://www.ocsinventory-ng.org                                           //
//                                                                                //
//                                                                                //
// This code is open source and may be copied and modified as long as the source  //
// code is always made freely available.                                          //
// Please refer to the General Public Licence http://www.gnu.org/                 //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////


#import "ExportWindowController.h"

#import "Context.h"
#import "ConfigurationWindowController.h"
#import "Configuration.h"


@implementation ExportWindowController


-(id) initWithContext:(Context *)contextObject {
    
    if (self = [super initWithWindowNibName:@"ExportWindow"]) {
        [context release];
        context = [contextObject retain];
        
        configuration = [context configuration];
        configurationWindowController = [context configurationWindowController];
        
        filemgr = [NSFileManager defaultManager];
        
        
        
    }
    return self;
    
}

- (void)awakeFromNib {
    
    //Filling defaults values
    [exportFileName setStringValue:@"ocspackage"];
}


- (IBAction) generatePackage:(id)sender {
    
    NSMutableString *ocsAgentCfgContent = nil;
    NSMutableString *modulesCfgContent;
    NSMutableString *protocolName;
    NSMutableString *launchdCfgFile;
    NSString *serverDir;
    NSString *finalMessageComment;
    
    //No export path filled
    if ( !([[exportPath stringValue] length] > 0 )) {
        [context displayAlert:NSLocalizedString(@"Invalid_export_path", @"Warning about invalid export path") comment:NSLocalizedString(@"Invalid_export_path_comment", @"Warning about invalid export path comment") style:NSAlertStyleCritical];
        return;
    }
    
    //No file name filled
    if ( !([[exportFileName stringValue] length] > 0 )) {
        [context displayAlert:NSLocalizedString(@"Invalid_export_file_name", @"Warning about invalid export file name") comment:NSLocalizedString(@"Invalid_export_file_name_comment", @"Warning about invalid export file name comment") style:NSAlertStyleCritical];
        return;
    }
    
    
    NSString *pkgFileName = [NSString stringWithFormat:@"%@.pkg",[exportFileName stringValue]];
    NSString *ocsPkgPath = [NSString stringWithFormat:@"%@/%@",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgPluginsPath = [NSString stringWithFormat:@"%@/%@/Contents/Plugins",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgResourcesPath = [NSString stringWithFormat:@"%@/%@/Contents/Resources",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgCfgFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/ocsinventory-agent.cfg",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgModulesFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/modules.conf",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgServerdirFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/serverdir",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgCacertFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/cacert.pem",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgLaunchdFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/org.ocsng.agent.plist",[exportPath stringValue],pkgFileName];
    NSString *ocsPkgNowFilePath = [NSString stringWithFormat:@"%@/%@/Contents/Resources/now",[exportPath stringValue],pkgFileName];
    
    //We check if package already exists
    if ([filemgr fileExistsAtPath:ocsPkgPath]) {
        NSAlert *existsWrn = [[NSAlert alloc] init];
        
        [existsWrn addButtonWithTitle:NSLocalizedString(@"Yes", @"Yes Button")];
        [existsWrn addButtonWithTitle:NSLocalizedString(@"No", @"No Button")];
        [existsWrn setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Package_already_exists_warn",@"Warning about already existing package file"),pkgFileName]];
        [existsWrn setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"Package_already_exists_warn_comment",@"Warning about already existing package file comment"),pkgFileName]];
        [existsWrn setAlertStyle:NSAlertStyleCritical];
        
        if ([existsWrn runModal] != NSAlertFirstButtonReturn) {
            //Button 'No' was clicked, we don't continue
            [existsWrn release];
            return;
        } else {
            //We delete file
            [existsWrn release];
            if(![self removeFile:ocsPkgPath]) {
                [context displayAlert:[NSString stringWithFormat:NSLocalizedString(@"Package_remove_error_warn", @"Warning about package remove error"),pkgFileName] comment:NSLocalizedString(@"Package_remove_error_warn_comment",@"Warning about package remove error comment") style:NSAlertStyleCritical];
                return;
            }
        }
    }
    
    //We create new package  file
    if (![filemgr copyItemAtPath:[configuration ocsPkgFilePath] toPath:ocsPkgPath error:nil]) {
        // if (![filemgr copyPath:[configuration ocsPkgFilePath] toPath:ocsPkgPath handler:nil]) {
        [context displayAlert:[NSString stringWithFormat: NSLocalizedString(@"Package_copy_error_warn", @"Warning about package copy error"),pkgFileName] comment:NSLocalizedString(@"Package_copy_error_warn_comment",@"Warning about package copy error comment") style:NSAlertStyleCritical];
        return;
    }
    
    //We delete plugins directory for future silent installs
    if (![self removeFile:ocsPkgPluginsPath]) {
        [context displayAlert:[NSString stringWithFormat:NSLocalizedString(@"Plugins_remove_error_warn", @"Warning about plugins directory remove error"),pkgFileName] comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment",@"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
        [self removeFile:ocsPkgPath];
        return;
    }
    
    //We copy preinstall and preupgrade scripts
    NSString *preinstallPath = [NSString stringWithFormat:@"%@/preinstall",[[NSBundle mainBundle] resourcePath]];
    
    if ([filemgr fileExistsAtPath:preinstallPath]) {
        // change from copyPath (deprecated) to copyItemAtPath
        if (![filemgr copyItemAtPath:preinstallPath toPath:[NSString stringWithFormat:@"%@/preinstall",ocsPkgResourcesPath] error:nil]) {
            // if (![filemgr copyPath:preinstallPath toPath:[NSString stringWithFormat:@"%@/preinstall",ocsPkgResourcesPath] handler:nil]) {
            [context displayAlert:NSLocalizedString(@"Preinstall_copy_error_warn",@"Warning about preinstall copy error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
            [self removeFile:ocsPkgPath];
            return;
        }
        
        // change from copyPath (deprecated) to copyItemAtPath
        if (![filemgr copyItemAtPath:preinstallPath toPath:[NSString stringWithFormat:@"%@/preupgrade",ocsPkgResourcesPath] error:nil]) {
            [context displayAlert:NSLocalizedString(@"Preupgrade_copy_error_warn",@"Warning about preupgrade copy error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
            [self removeFile:ocsPkgPath];
            return;
        }
    }
    
    //We create agent configuration files
    if ([[configuration server] length] > 0) {
        ocsAgentCfgContent = [@"server=" mutableCopy];
        
        //Adding server value to the mutable string
        [ocsAgentCfgContent appendString:[configuration protocol]];
        [ocsAgentCfgContent appendString:[configuration server]];
        [ocsAgentCfgContent appendString:@"/ocsinventory"];
        [ocsAgentCfgContent appendString:@"\n"];
    }
    
    if ([[configuration tag] length] > 0) {
        [ocsAgentCfgContent appendString:@"tag="];
        [ocsAgentCfgContent appendString:[configuration tag]];
        [ocsAgentCfgContent appendString:@"\n"];
    }
    
    if ([[configuration logfile] length] > 0) {
        [ocsAgentCfgContent appendString:@"logfile="];
        [ocsAgentCfgContent appendString:[configuration logfile]];
        [ocsAgentCfgContent appendString:@"\n"];
    }
    
    if ([configuration debugmode]) {
        [ocsAgentCfgContent appendString:@"debug=1\n"];
    } else {
        [ocsAgentCfgContent appendString:@"debug=0\n"];
    }
    
    if ([configuration lazy]) {
        [ocsAgentCfgContent appendString:@"lazy=1\n"];
    } else {
        [ocsAgentCfgContent appendString:@"lazy=0\n"];
    }
    
    if(![ocsAgentCfgContent writeToFile:ocsPkgCfgFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL]) {
        [context displayAlert:NSLocalizedString(@"Configuration_file_write_error_warn",@"Warning about ocsinventory-agent.cfg file write error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
        [self removeFile:ocsPkgPath];
        return;
    }
    
    //We create modules configuration files
    modulesCfgContent = [@"# this list of module will be load by the at run time\n"
                         @"# to check its syntax do:\n"
                         @"# #perl modules.conf\n"
                         @"# You must have NO error. Else the content will be ignored\n"
                         @"# This mechanism goal it to keep compatibility with 'plugin'\n"
                         @"# created for the previous linux_agent.\n"
                         @"# The new unified_agent have its own extension system that allow\n"
                         @"# user to add new information easily.\n"
                         @"\n"
                         @"#use Ocsinventory::Agent::Modules::Example;\n"
                         mutableCopy];
    
    if ( [configuration download] == 1) {
        [modulesCfgContent appendString:@"use Ocsinventory::Agent::Modules::Download;\n"];
    } else {
        [modulesCfgContent appendString:@"#use Ocsinventory::Agent::Modules::Download;\n"];
    }
    
    [modulesCfgContent appendString:@"\n"
     @"# DO NOT REMOVE THE 1;\n"
     @"1;"
     ];
    
    if (![modulesCfgContent writeToFile:ocsPkgModulesFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL]) {
        [context displayAlert:NSLocalizedString(@"Modules_file_write_error_warn",@"Warning about modules.conf file write error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
        [self removeFile:ocsPkgPath];
        return;
    }
    
    
    //We copy cacertfile and create file for server directory creation
    if ([[configuration cacertFilePath] length] > 0) {
        
        protocolName = [[configuration protocol] mutableCopy];
        [protocolName replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [protocolName length])];
        
        serverDir = [NSString stringWithFormat:@"/var/lib/ocsinventory-agent/%@__%@_ocsinventory", protocolName, [configuration server]];
        [serverDir writeToFile:ocsPkgServerdirFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL];
        
        // change from copyPath (deprecated) to copyItemAtPath
        if (![filemgr copyItemAtPath:[configuration cacertFilePath] toPath:ocsPkgCacertFilePath error:nil]) {
            [context displayAlert:NSLocalizedString(@"Cacert_file_copy_error_warn",@"Warning about cacert.pem file copy error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
            [self removeFile:ocsPkgPath];
            return;
        }
    }
    
    
    //We create launchd configuration file
    //TODO: use XML parser instead of writing the XML as a simple text file ?
    launchdCfgFile = [@"<?xml version='1.0' encoding='UTF-8'?>\n"
                      @"<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>\n"
                      @"<plist version='1.0'>\n"
                      @"<dict>\n"
                      @"\t<key>Label</key>\n"
                      @"\t<string>org.ocsng.agent</string>\n"
                      @"\t<key>ProgramArguments</key>\n"
                      @"\t\t<array>\n"
                      @"\t\t\t<string>/Applications/OCSNG.app/Contents/MacOS/OCSNG</string>\n"
                      @"\t\t</array>\n"
                      mutableCopy];
    
    
    if ([configuration startup] == 1) {
        [launchdCfgFile  appendString:@"\t<key>RunAtLoad</key>\n"
         @"\t<true/>\n"
         ];
    }
    
    if ( [[configuration periodicity] length] > 0) {
        //We convert string to numeric value and check if it is integer
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *convert = [formatter numberFromString:[configuration periodicity]];
        [formatter release];
        
        if (convert) {
            int hours = [convert intValue];
            int seconds =  hours * 3600;
            
            [launchdCfgFile  appendString:@"\t<key>StartInterval</key>\n"
             @"\t<integer>"
             ];
            
            [launchdCfgFile  appendString:[NSString stringWithFormat:@"%d", seconds]];
            [launchdCfgFile  appendString:@"</integer>\n"];
            
        } else {
            //Invalid periodificty value
            [context displayAlert:NSLocalizedString(@"Periodicity_warn", @"Peridocity warn") comment:NSLocalizedString(@"Periodicity_warn_comment", @"Periodicity warn comment") style:NSAlertStyleCritical];
            [self removeFile:ocsPkgPath];
            return;
        }
    }
    
    [launchdCfgFile appendString:@"</dict>\n"
     @"</plist>"
     ];
    
    if (![launchdCfgFile writeToFile:ocsPkgLaunchdFilePath atomically: YES encoding:NSUTF8StringEncoding error:NULL]) {
        [context displayAlert:NSLocalizedString(@"Launchd_file_write_error_warn",@"Warning about org.ocsng.agent.plit file write error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
        [self removeFile:ocsPkgPath];
        return;
    }
    
    
    //We create now file if needed
    if ([configuration now] == 1) {
        if (![filemgr createFileAtPath:ocsPkgNowFilePath contents:nil attributes:nil]) {
            [context displayAlert:NSLocalizedString(@"Now_file_write_error_warn",@"Warning about now file write error") comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName] style:NSAlertStyleCritical];
            [self removeFile:ocsPkgPath];
            return;
        }
    }
    
    
    //Everything OK and package generated succefully
    finalMessageComment = [NSString stringWithFormat:NSLocalizedString(@"Package_succesfully_created_comment",@"Message for succefull created package_comment"), pkgFileName, [exportPath stringValue]];
    [context displayAlert:NSLocalizedString(@"Package_succesfully_created",@"Message for succefull created package") comment:finalMessageComment style:NSAlertStyleInformational];
    [NSApp terminate:self];
}


//To quit application
- (IBAction) terminateApp:(id)sender {
    [NSApp terminate:self];
}

- (IBAction) backConfigurationWindow:(id)sender {
    
    [[configurationWindowController window] orderFront:sender];
    [[self window] orderOut:sender];
}

- (IBAction) chooseExportPath:(id)sender {
    
    //Configuration for the browse panel
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setAllowsMultipleSelection:NO];
    
    
    //Running browse panel
    NSInteger result = [panel runModal];
    
    //Getting cacert file path
    if (result == NSModalResponseOK) {
        [exportPath setStringValue:[[panel URL] path]];
    }
}

- (BOOL) removeFile:(NSString *)path {
    BOOL returnValue = YES;
    
    if ([filemgr fileExistsAtPath:path]) {
        // change from removeFileAtPath (deprecated) to removeItemAtPAth
        returnValue = [filemgr removeItemAtPath:path error:nil];
    }
    
    return returnValue;
}


//Famous dealloc for memory management
- (void) dealloc {
    [context release];
    [super dealloc];
    
}

@end
