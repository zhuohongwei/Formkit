#Formkit

An Objective-C library for creating forms easily.

##Creating a form

We have included `FKFormViewController`, a convenient UIViewController subclass to create and show a form. 

As an example, these are the steps to create a view controller that shows a login form:

First, subclass `FKFormViewController`
```
@interface FKLoginViewController : FKFormViewController
@end
```

Next, set the `form` property. `FKFormViewController` has a `form` property. During initialization, configure and set form in your subclass as follows:
```
FKForm *form = [[FKForm alloc] init];
form.title = @"Sign In";
    
FKRowItem *row1 = [form addRow];
[row1 addColumnWithItem:[FKTextFieldItem textFieldItemWithName:@"username" label:@"Username" text:nil placeholder:@"Email address"]];
    
FKRowItem *row2 = [form addRow];
[row2 addColumnWithItem:[FKTextFieldItem textFieldItemWithName:@"password" label:@"Password" text:nil placeholder:nil]];
    
form.purpose = FKFormPurposeSubmit;
form.submitLabel = @"Sign In";
    
self.form = form;
```

Lastly, perform any customization in `viewDidLoad`. The view associated with the form will be available at this point of time:
```
FKTextFieldItem *passwordItem = (FKTextFieldItem *)[self.form inputItemNamed:@"password"];
FKTextFieldView *passwordField = (FKTextFieldView *) passwordItem.view;
passwordField.textField.secureTextEntry = YES;
```


##Submitting the form
`FKFormViewController` provides methods which you can override for handling form submission and cancellation actions.
```
//Methods to override in subclass, do not call directly
-(void)cancel:(id)sender;
-(void)submit:(id)sender;
```

For example, you can do the following in your subclass:
```
-(void)submit:(id)sender {
    //get all the form values
    NSDictionary *allFormValues = [self.form allValues];
}
```
