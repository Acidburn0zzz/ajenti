angular.module('core').factory 'unauthenticatedInterceptor', ($q, $rootScope, $location, $window, notify, urlPrefix, messagebox, gettext) ->
    return {
        responseError: (rejection) ->
            if rejection.status == 0
                ; # todo
                #notify.error 'Could not connect'

            if rejection.status == 500 and rejection.data.exception == 'SecurityError'
                notify.error gettext('Security error'), rejection.data.message

            else if rejection.status == 500 and rejection.data.exception != 'EndpointError'
                messagebox.show title: gettext('Server error'), data: rejection, template: '/core:resources/partial/serverErrorMessage.html', scrollable: true, negative: gettext('Close')

            else if rejection.status == 401
                if $rootScope.disableExpiredSessionInterceptor or $location.path().indexOf("#{urlPrefix}/view/login") == 0
                    return $q.reject(rejection)

                $rootScope.disableExpiredSessionInterceptor = true
                notify.error gettext('Your session has expired')
                $window.location.assign("#{urlPrefix}/view/login/normal/#{$location.path()}")
                #identity.login() # circular dep - TODO

            return $q.reject(rejection)
    }


angular.module('core').factory 'urlPrefixInterceptor', ($q, $rootScope, $location, notify, urlPrefix) ->
    return {
        request: (config) ->
            if config.url and config.url[0] == '/'
                config.url = urlPrefix + config.url
            return config
    }