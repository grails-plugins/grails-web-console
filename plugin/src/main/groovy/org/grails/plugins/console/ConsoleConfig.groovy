package org.grails.plugins.console

import grails.config.Config
import grails.util.Environment

class ConsoleConfig {

    boolean enabled
    String newFileText
    boolean indentWithTabs
    int tabSize
    int indentUnit
    String remoteFileStoreDefaultPath
    boolean remoteFileStoreEnabled
    boolean csrfProtectionEnabled
    def baseUrl

    ConsoleConfig(Config config, String basePath) {
        enabled = config.getProperty("${basePath}${basePath ? '.' : ''}enabled", Boolean, Environment.current == Environment.DEVELOPMENT)
        newFileText = config.getProperty("${basePath}${basePath ? '.' : ''}newFileText") as String
        indentWithTabs = config.getProperty("${basePath}${basePath ? '.' : ''}indentWithTabs", Boolean, false)
        tabSize = config.getProperty("${basePath}${basePath ? '.' : ''}tabSize", Integer, 4)
        indentUnit = config.getProperty("${basePath}${basePath ? '.' : ''}indentUnit", Integer, 4)
        remoteFileStoreDefaultPath = config.getProperty("${basePath}${basePath ? '.' : ''}fileStore.remote.defaultPath") as String
        remoteFileStoreEnabled = config.getProperty("${basePath}${basePath ? '.' : ''}fileStore.remote.enabled", Boolean, true)
        csrfProtectionEnabled = config.getProperty("${basePath}${basePath ? '.' : ''}csrfProtection.enabled", Boolean, true)

        def configuredBaseUrl = config.getProperty("${basePath}${basePath ? '.' : ''}baseUrl")
        if(configuredBaseUrl instanceof GString) {
            configuredBaseUrl = configuredBaseUrl.toString()
        }
        if (configuredBaseUrl instanceof List || configuredBaseUrl instanceof String) {
            baseUrl = configuredBaseUrl
        }
    }
}
