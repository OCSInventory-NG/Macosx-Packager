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

@interface ExportWindowController ()

- (BOOL)generateBundlePackageAtPath:(NSString *)outputPackagePath pkgFileName:(NSString *)pkgFileName preinstallPath:(NSString *)preinstallPath;
- (BOOL)generateFlatPackageAtPath:(NSString *)outputPackagePath pkgFileName:(NSString *)pkgFileName preinstallPath:(NSString *)preinstallPath;
- (BOOL)writeCustomizationFilesAtResourcesPath:(NSString *)resourcesPath pkgFileName:(NSString *)pkgFileName cleanupPaths:(NSArray *)cleanupPaths;
- (BOOL)stageFlatCustomizationFilesFromResourcesPath:(NSString *)resourcesPath scriptsPath:(NSString *)scriptsPath pkgFileName:(NSString *)pkgFileName cleanupPaths:(NSArray *)cleanupPaths;
- (BOOL)copyFileAtPath:(NSString *)sourcePath toPath:(NSString *)targetPath replaceExisting:(BOOL)replaceExisting errorMessageKey:(NSString *)errorMessageKey pkgFileName:(NSString *)pkgFileName cleanupPaths:(NSArray *)cleanupPaths;
- (BOOL)runCommandAtPath:(NSString *)commandPath arguments:(NSArray *)arguments output:(NSString **)commandOutput;
- (NSString *)commandFailureCommentWithBaseKey:(NSString *)commentKey output:(NSString *)commandOutput;
- (NSString *)temporaryWorkspacePath;
- (NSString *)flatComponentPackagePathAtExpandedPath:(NSString *)expandedPath;
- (BOOL)isValidFlatPackageAtExpandedPath:(NSString *)expandedPath componentPackagePath:(NSString **)componentPackagePath;
- (BOOL)cleanupPaths:(NSArray *)paths showWarning:(BOOL)showWarning;
- (BOOL)displayErrorWithMessage:(NSString *)message comment:(NSString *)comment cleanupPaths:(NSArray *)cleanupPaths;

@end


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
    
    NSString *finalMessageComment;
    NSString *sourcePackagePath = [configuration ocsPkgFilePath];
    BOOL sourceIsDirectory = NO;
    BOOL generationSucceeded = NO;
    
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
    NSString *preinstallPath = [NSString stringWithFormat:@"%@/preinstall",[[NSBundle mainBundle] resourcePath]];
    
    if (![filemgr fileExistsAtPath:sourcePackagePath isDirectory:&sourceIsDirectory]) {
        [context displayAlert:NSLocalizedString(@"Invalid_pkg_file", @"Warning about invalid OCS package file") comment:NSLocalizedString(@"Invalid_pkg_file_comment", @"Warning about invalid OCS package comment") style:NSAlertStyleCritical];
        return;
    }
    
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
    
    if (sourceIsDirectory) {
        generationSucceeded = [self generateBundlePackageAtPath:ocsPkgPath pkgFileName:pkgFileName preinstallPath:preinstallPath];
    } else {
        generationSucceeded = [self generateFlatPackageAtPath:ocsPkgPath pkgFileName:pkgFileName preinstallPath:preinstallPath];
    }
    
    if (!generationSucceeded) {
        return;
    }
    
    
    //Everything OK and package generated successfully
    finalMessageComment = [NSString stringWithFormat:NSLocalizedString(@"Package_succesfully_created_comment",@"Message for succefull created package_comment"), pkgFileName, [exportPath stringValue]];
    [context displayAlert:NSLocalizedString(@"Package_succesfully_created",@"Message for succefull created package") comment:finalMessageComment style:NSAlertStyleInformational];
    [NSApp terminate:self];
}

- (BOOL)generateBundlePackageAtPath:(NSString *)outputPackagePath pkgFileName:(NSString *)pkgFileName preinstallPath:(NSString *)preinstallPath {
    NSString *resourcesPath = [outputPackagePath stringByAppendingPathComponent:@"Contents/Resources"];
    NSString *pluginsPath = [outputPackagePath stringByAppendingPathComponent:@"Contents/Plugins"];
    NSArray *cleanupPaths = [NSArray arrayWithObject:outputPackagePath];
    
    if (![filemgr copyItemAtPath:[configuration ocsPkgFilePath] toPath:outputPackagePath error:nil]) {
        return [self displayErrorWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Package_copy_error_warn", @"Warning about package copy error"),pkgFileName]
                                     comment:NSLocalizedString(@"Package_copy_error_warn_comment",@"Warning about package copy error comment")
                                cleanupPaths:cleanupPaths];
    }
    
    if (![self removeFile:pluginsPath]) {
        return [self displayErrorWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Plugins_remove_error_warn", @"Warning about plugins directory remove error"),pkgFileName]
                                     comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment",@"Warning about package write error comment"),pkgFileName]
                                cleanupPaths:cleanupPaths];
    }
    
    if (![self copyFileAtPath:preinstallPath
                       toPath:[resourcesPath stringByAppendingPathComponent:@"preinstall"]
              replaceExisting:YES
              errorMessageKey:@"Preinstall_copy_error_warn"
                  pkgFileName:pkgFileName
                 cleanupPaths:cleanupPaths]) {
        return NO;
    }
    
    if (![self copyFileAtPath:preinstallPath
                       toPath:[resourcesPath stringByAppendingPathComponent:@"preupgrade"]
              replaceExisting:YES
              errorMessageKey:@"Preupgrade_copy_error_warn"
                  pkgFileName:pkgFileName
                 cleanupPaths:cleanupPaths]) {
        return NO;
    }
    
    return [self writeCustomizationFilesAtResourcesPath:resourcesPath pkgFileName:pkgFileName cleanupPaths:cleanupPaths];
}

- (BOOL)generateFlatPackageAtPath:(NSString *)outputPackagePath pkgFileName:(NSString *)pkgFileName preinstallPath:(NSString *)preinstallPath {
    NSString *workspacePath = [self temporaryWorkspacePath];
    NSString *expandedPath = [workspacePath stringByAppendingPathComponent:@"expanded"];
    NSString *resourcesPath = [expandedPath stringByAppendingPathComponent:@"Resources"];
    NSString *componentPackagePath = nil;
    NSString *scriptsPath = nil;
    NSString *commandOutput = nil;
    NSArray *cleanupPaths = [NSArray arrayWithObjects:workspacePath, outputPackagePath, nil];
    
    if (![filemgr createDirectoryAtPath:workspacePath withIntermediateDirectories:YES attributes:nil error:nil]) {
        return [self displayErrorWithMessage:NSLocalizedString(@"Temp_workspace_create_warn", @"Warning about temporary package workspace create error")
                                     comment:NSLocalizedString(@"Temp_workspace_create_warn_comment", @"Warning about temporary package workspace create error comment")
                                cleanupPaths:nil];
    }
    
    if (![self runCommandAtPath:@"/usr/sbin/pkgutil"
                      arguments:[NSArray arrayWithObjects:@"--expand", [configuration ocsPkgFilePath], expandedPath, nil]
                         output:&commandOutput]) {
        return [self displayErrorWithMessage:NSLocalizedString(@"Flat_pkg_expand_warn", @"Warning about flat package expand error")
                                     comment:[self commandFailureCommentWithBaseKey:@"Flat_pkg_expand_warn_comment" output:commandOutput]
                                cleanupPaths:cleanupPaths];
    }
    
    if (![self isValidFlatPackageAtExpandedPath:expandedPath componentPackagePath:&componentPackagePath]) {
        return [self displayErrorWithMessage:NSLocalizedString(@"Unsupported_flat_pkg_warn", @"Warning about unsupported flat package")
                                     comment:NSLocalizedString(@"Unsupported_flat_pkg_warn_comment", @"Warning about unsupported flat package comment")
                                cleanupPaths:cleanupPaths];
    }
    scriptsPath = [componentPackagePath stringByAppendingPathComponent:@"Scripts"];
    
    if (![self removeFile:[expandedPath stringByAppendingPathComponent:@"Plugins"]]) {
        return [self displayErrorWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Plugins_remove_error_warn", @"Warning about plugins directory remove error"),pkgFileName]
                                     comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment",@"Warning about package write error comment"),pkgFileName]
                                cleanupPaths:cleanupPaths];
    }
    
    if (![self copyFileAtPath:preinstallPath
                       toPath:[scriptsPath stringByAppendingPathComponent:@"preinstall"]
              replaceExisting:YES
              errorMessageKey:@"Preinstall_copy_error_warn"
                  pkgFileName:pkgFileName
                 cleanupPaths:cleanupPaths]) {
        return NO;
    }
    
    if (![self writeCustomizationFilesAtResourcesPath:resourcesPath pkgFileName:pkgFileName cleanupPaths:cleanupPaths]) {
        return NO;
    }
    
    if (![self stageFlatCustomizationFilesFromResourcesPath:resourcesPath scriptsPath:scriptsPath pkgFileName:pkgFileName cleanupPaths:cleanupPaths]) {
        return NO;
    }
    
    commandOutput = nil;
    if (![self runCommandAtPath:@"/usr/sbin/pkgutil"
                      arguments:[NSArray arrayWithObjects:@"--flatten", expandedPath, outputPackagePath, nil]
                         output:&commandOutput]) {
        return [self displayErrorWithMessage:NSLocalizedString(@"Flat_pkg_flatten_warn", @"Warning about flat package flatten error")
                                     comment:[self commandFailureCommentWithBaseKey:@"Flat_pkg_flatten_warn_comment" output:commandOutput]
                                cleanupPaths:cleanupPaths];
    }
    
    [self cleanupPaths:[NSArray arrayWithObject:workspacePath] showWarning:YES];
    return YES;
}

- (BOOL)writeCustomizationFilesAtResourcesPath:(NSString *)resourcesPath pkgFileName:(NSString *)pkgFileName cleanupPaths:(NSArray *)cleanupPaths {
    NSMutableString *ocsAgentCfgContent = nil;
    NSMutableString *modulesCfgContent = nil;
    NSMutableString *protocolName = nil;
    NSMutableString *launchdCfgFile = nil;
    NSString *serverDir = nil;
    NSString *cfgFilePath = [resourcesPath stringByAppendingPathComponent:@"ocsinventory-agent.cfg"];
    NSString *modulesFilePath = [resourcesPath stringByAppendingPathComponent:@"modules.conf"];
    NSString *serverdirFilePath = [resourcesPath stringByAppendingPathComponent:@"serverdir"];
    NSString *cacertFilePath = [resourcesPath stringByAppendingPathComponent:@"cacert.pem"];
    NSString *launchdFilePath = [resourcesPath stringByAppendingPathComponent:@"org.ocsng.agent.plist"];
    NSString *nowFilePath = [resourcesPath stringByAppendingPathComponent:@"now"];
    
    //We create agent configuration files
    if ([[configuration server] length] > 0) {
        ocsAgentCfgContent = [@"server=" mutableCopy];
        
        //Adding server value to the mutable string
        [ocsAgentCfgContent appendString:[configuration protocol]];
        [ocsAgentCfgContent appendString:[configuration server]];
        [ocsAgentCfgContent appendString:@"\n"];
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
    
    if ([configuration ssl]) {
        [ocsAgentCfgContent appendString:@"ssl=1\n"];
    } else {
        [ocsAgentCfgContent appendString:@"ssl=0\n"];
    }
    
    if ([configuration authUser]) {
        [ocsAgentCfgContent appendString:@"user="];
        NSData *user = [[configuration authUser] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *userEncoded = [user base64EncodedStringWithOptions:kNilOptions];
        [ocsAgentCfgContent appendString:userEncoded];
        [ocsAgentCfgContent appendString:@"\n"];
    }
    
    if ([configuration authPwd]) {
        [ocsAgentCfgContent appendString:@"password="];
        NSData *pwd = [[configuration authPwd] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *pwdEncoded = [pwd base64EncodedStringWithOptions:kNilOptions];
        [ocsAgentCfgContent appendString:pwdEncoded];
        [ocsAgentCfgContent appendString:@"\n"];
    }
    
    if ([configuration authRealm]) {
        [ocsAgentCfgContent appendString:@"realm="];
        [ocsAgentCfgContent appendString:[configuration authRealm]];
        [ocsAgentCfgContent appendString:@"\n"];
    }
    
    if(![ocsAgentCfgContent writeToFile:cfgFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [ocsAgentCfgContent release];
        return [self displayErrorWithMessage:NSLocalizedString(@"Configuration_file_write_error_warn",@"Warning about ocsinventory-agent.cfg file write error")
                                     comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName]
                                cleanupPaths:cleanupPaths];
    }
    [ocsAgentCfgContent release];
    
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
    
    if (![modulesCfgContent writeToFile:modulesFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [modulesCfgContent release];
        return [self displayErrorWithMessage:NSLocalizedString(@"Modules_file_write_error_warn",@"Warning about modules.conf file write error")
                                     comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName]
                                cleanupPaths:cleanupPaths];
    }
    [modulesCfgContent release];
    
    
    //We copy cacertfile and create file for server directory creation
    if ([[configuration cacertFilePath] length] > 0) {
        
        protocolName = [[configuration protocol] mutableCopy];
        [protocolName replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [protocolName length])];
        
        serverDir = [NSString stringWithFormat:@"/var/lib/ocsinventory-agent/%@__%@_ocsinventory", protocolName, [configuration server]];
        [serverDir writeToFile:serverdirFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        [protocolName release];
        
        if (![self copyFileAtPath:[configuration cacertFilePath]
                           toPath:cacertFilePath
                  replaceExisting:YES
                  errorMessageKey:@"Cacert_file_copy_error_warn"
                      pkgFileName:pkgFileName
                     cleanupPaths:cleanupPaths]) {
            return NO;
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
            [launchdCfgFile release];
            return [self displayErrorWithMessage:NSLocalizedString(@"Periodicity_warn", @"Peridocity warn")
                                         comment:NSLocalizedString(@"Periodicity_warn_comment", @"Periodicity warn comment")
                                    cleanupPaths:cleanupPaths];
        }
    }
    
    [launchdCfgFile appendString:@"</dict>\n"
     @"</plist>"
     ];
    
    if (![launchdCfgFile writeToFile:launchdFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [launchdCfgFile release];
        return [self displayErrorWithMessage:NSLocalizedString(@"Launchd_file_write_error_warn",@"Warning about org.ocsng.agent.plit file write error")
                                     comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName]
                                cleanupPaths:cleanupPaths];
    }
    [launchdCfgFile release];
    
    
    //We create now file if needed
    if ([configuration now] == 1) {
        if (![filemgr createFileAtPath:nowFilePath contents:nil attributes:nil]) {
            return [self displayErrorWithMessage:NSLocalizedString(@"Now_file_write_error_warn",@"Warning about now file write error")
                                         comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName]
                                    cleanupPaths:cleanupPaths];
        }
    }
    
    return YES;
}

- (BOOL)stageFlatCustomizationFilesFromResourcesPath:(NSString *)resourcesPath scriptsPath:(NSString *)scriptsPath pkgFileName:(NSString *)pkgFileName cleanupPaths:(NSArray *)cleanupPaths {
    NSArray *requiredFiles = [NSArray arrayWithObjects:@"ocsinventory-agent.cfg", @"modules.conf", @"org.ocsng.agent.plist", nil];
    NSArray *optionalFiles = [NSArray arrayWithObjects:@"serverdir", @"cacert.pem", @"now", nil];
    NSEnumerator *enumerator = [requiredFiles objectEnumerator];
    NSString *fileName = nil;
    
    while ((fileName = [enumerator nextObject])) {
        NSString *sourcePath = [resourcesPath stringByAppendingPathComponent:fileName];
        NSString *targetPath = [scriptsPath stringByAppendingPathComponent:fileName];
        
        if (![filemgr fileExistsAtPath:sourcePath]) {
            return [self displayErrorWithMessage:NSLocalizedString(@"Flat_pkg_stage_warn", @"Warning about flat package staging error")
                                         comment:[NSString stringWithFormat:NSLocalizedString(@"Flat_pkg_stage_warn_comment", @"Warning about flat package staging error comment"), fileName]
                                    cleanupPaths:cleanupPaths];
        }
        
        if (![self copyFileAtPath:sourcePath
                           toPath:targetPath
                  replaceExisting:YES
                  errorMessageKey:@"Flat_pkg_stage_warn"
                      pkgFileName:pkgFileName
                     cleanupPaths:cleanupPaths]) {
            return NO;
        }
    }
    
    enumerator = [optionalFiles objectEnumerator];
    while ((fileName = [enumerator nextObject])) {
        NSString *sourcePath = [resourcesPath stringByAppendingPathComponent:fileName];
        NSString *targetPath = [scriptsPath stringByAppendingPathComponent:fileName];
        
        if (![filemgr fileExistsAtPath:sourcePath]) {
            continue;
        }
        
        if (![self copyFileAtPath:sourcePath
                           toPath:targetPath
                  replaceExisting:YES
                  errorMessageKey:@"Flat_pkg_stage_warn"
                      pkgFileName:pkgFileName
                     cleanupPaths:cleanupPaths]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)copyFileAtPath:(NSString *)sourcePath toPath:(NSString *)targetPath replaceExisting:(BOOL)replaceExisting errorMessageKey:(NSString *)errorMessageKey pkgFileName:(NSString *)pkgFileName cleanupPaths:(NSArray *)cleanupPaths {
    if (replaceExisting && [filemgr fileExistsAtPath:targetPath]) {
        if (![filemgr removeItemAtPath:targetPath error:nil]) {
            return [self displayErrorWithMessage:NSLocalizedString(errorMessageKey, @"Warning about packaged file copy error")
                                         comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName]
                                    cleanupPaths:cleanupPaths];
        }
    }
    
    if (![filemgr copyItemAtPath:sourcePath toPath:targetPath error:nil]) {
        return [self displayErrorWithMessage:NSLocalizedString(errorMessageKey, @"Warning about packaged file copy error")
                                     comment:[NSString stringWithFormat:NSLocalizedString(@"Package_write_error_warn_comment", @"Warning about package write error comment"),pkgFileName]
                                cleanupPaths:cleanupPaths];
    }
    
    return YES;
}

- (BOOL)runCommandAtPath:(NSString *)commandPath arguments:(NSArray *)arguments output:(NSString **)commandOutput {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSData *commandData;
    NSString *capturedOutput = @"";
    BOOL success = NO;
    
    [task setLaunchPath:commandPath];
    [task setArguments:arguments];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    
    @try {
        [task launch];
        [task waitUntilExit];
        commandData = [[pipe fileHandleForReading] readDataToEndOfFile];
        if ([commandData length] > 0) {
            NSString *decodedOutput = [[[NSString alloc] initWithData:commandData encoding:NSUTF8StringEncoding] autorelease];
            if (decodedOutput) {
                capturedOutput = decodedOutput;
            }
        }
        success = ([task terminationStatus] == 0);
    }
    @catch (NSException *exception) {
        capturedOutput = [exception reason];
    }
    
    if (commandOutput != NULL) {
        *commandOutput = capturedOutput;
    }
    
    [task release];
    return success;
}

- (NSString *)commandFailureCommentWithBaseKey:(NSString *)commentKey output:(NSString *)commandOutput {
    NSString *outputString = commandOutput;
    
    if (![outputString length]) {
        outputString = @"";
    }
    
    return [NSString stringWithFormat:NSLocalizedString(commentKey, @"Command failure comment"), outputString];
}

- (NSString *)temporaryWorkspacePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ocs-packager-%@", [[NSProcessInfo processInfo] globallyUniqueString]]];
}

- (NSString *)flatComponentPackagePathAtExpandedPath:(NSString *)expandedPath {
    NSArray *expandedContents = [filemgr contentsOfDirectoryAtPath:expandedPath error:nil];
    NSMutableArray *componentPackages = [NSMutableArray array];
    NSEnumerator *enumerator = [expandedContents objectEnumerator];
    NSString *entry = nil;
    
    while ((entry = [enumerator nextObject])) {
        BOOL isDirectory = NO;
        NSString *entryPath = [expandedPath stringByAppendingPathComponent:entry];
        
        if ([[entry pathExtension] isEqualToString:@"pkg"] && [filemgr fileExistsAtPath:entryPath isDirectory:&isDirectory] && isDirectory) {
            [componentPackages addObject:entryPath];
        }
    }
    
    if ([componentPackages count] != 1) {
        return nil;
    }
    
    return [componentPackages objectAtIndex:0];
}

- (BOOL)isValidFlatPackageAtExpandedPath:(NSString *)expandedPath componentPackagePath:(NSString **)componentPackagePath {
    BOOL isDirectory = NO;
    NSString *distributionPath = [expandedPath stringByAppendingPathComponent:@"Distribution"];
    NSString *resourcesPath = [expandedPath stringByAppendingPathComponent:@"Resources"];
    NSString *nestedComponentPackagePath = [self flatComponentPackagePathAtExpandedPath:expandedPath];
    
    if (![filemgr fileExistsAtPath:distributionPath]) {
        return NO;
    }
    
    if (![filemgr fileExistsAtPath:resourcesPath isDirectory:&isDirectory] || !isDirectory) {
        return NO;
    }
    
    if (!nestedComponentPackagePath) {
        return NO;
    }
    
    isDirectory = NO;
    if (![filemgr fileExistsAtPath:[nestedComponentPackagePath stringByAppendingPathComponent:@"Scripts"] isDirectory:&isDirectory] || !isDirectory) {
        return NO;
    }
    
    if (componentPackagePath != NULL) {
        *componentPackagePath = nestedComponentPackagePath;
    }
    
    return YES;
}

- (BOOL)cleanupPaths:(NSArray *)paths showWarning:(BOOL)showWarning {
    NSEnumerator *enumerator = [paths objectEnumerator];
    NSString *path = nil;
    
    while ((path = [enumerator nextObject])) {
        if ([path length] > 0 && ![self removeFile:path]) {
            if (showWarning) {
                [context displayAlert:NSLocalizedString(@"Temp_workspace_cleanup_warn", @"Warning about temporary package workspace cleanup error")
                              comment:[NSString stringWithFormat:NSLocalizedString(@"Temp_workspace_cleanup_warn_comment", @"Warning about temporary package workspace cleanup error comment"), path]
                                style:NSAlertStyleCritical];
            }
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)displayErrorWithMessage:(NSString *)message comment:(NSString *)comment cleanupPaths:(NSArray *)cleanupPaths {
    if (cleanupPaths) {
        [self cleanupPaths:cleanupPaths showWarning:NO];
    }
    [context displayAlert:message comment:comment style:NSAlertStyleCritical];
    return NO;
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
