//
//  ContentView.swift
//  adminAPI
//
//  Created by Law, Michael on 3/26/21.
//

import SwiftUI
import Amplify
import AmplifyPlugins
import Combine

class ContentViewModel: ObservableObject {
    var cancellable: AnyCancellable?
    func getUser() {
        let path = "/getUser"
        let query = ["username": "micael"]
        let request = RESTRequest(path: path, queryParameters: query, body: nil)
        cancellable = Amplify.API.get(request: request)
            .resultPublisher
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                switch completion {
                case .failure(let err):
                    print(err)
                    if case let .httpStatusError(statusCode, response) = err,
                       let awsResponse = response as? AWSHTTPURLResponse,
                       let responseBody = awsResponse.body
                    {
                        let str = String(decoding: responseBody, as: UTF8.self)
                        print(str)
                    }
                case .finished:
                    print("call to admin query api complete")
                }
            } receiveValue: { (data) in
                let str = String(decoding: data, as: UTF8.self)
                print("Success \(str)")
            }
        
    }
}
struct ContentView: View {
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                } else {
                    print("SignUp Complete")
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
    
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    func signOutGlobally() {
        Amplify.Auth.signOut(options: .init(globalSignOut: true)) { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    @ObservedObject var vm = ContentViewModel()
    
    var body: some View {
        VStack {
            Button("signUp", action: {
                self.signUp(username: "micael", password: "password", email: "EMAIL@EMAIL.com")
            })
            Button("confirm sign up") {
                self.confirmSignUp(for: "micael", with: "270784")
            }
            Button("sign in") {
                self.signIn(username: "micael", password: "password")
            }
            Button("sign out") {
                self.signOutGlobally()
            }
            Button("test", action: {
                self.vm.getUser()
            })
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
