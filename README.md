#Formkit

An Objective-C library for creating forms easily.

##Quick start

###Creating a form

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


###Submitting the form
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


##Formkit Design

###Formkit class hierachy

The two base classes of Formkit are `FKFormItem` and `FKFormItemView`. Each `FKFormItem` subclass is related to a `FKFormItemView` subclass.

- `FKFormItem`
    - `FKForm`
    - `FKRowItem`
    - `FKColumnItem`
    - `FKInputItem`
        - `FKTextFieldItem`
        - `FKSelectFieldItem`
        - Other input __model__ classes...

- `FKFormItemView`
    - `FKFormView`
    - `FKFormRowView`
    - `FKFormColumnView`
    - `FKInputControlView`
        - `FKTextFieldView`
        - `FKSelectFieldView`
        - Other input __view__ classes
 
###What makes up a form

In Formkit, each form is represented as a tree with the root being an instance of `FKForm`.

An `FKForm` contains 1..N `FKRowItem`s representing rows.

Each `FKRowItem` contains 1..N `FKColumnItem`s representing columns.

Each `FKColumnItem` contains a single `FKInputItem` subclass object representing an input field.

###Extending formkit

####writing your own input controls

As an example, let's implement a text area input control, `FKSampleTextAreaItem`.

Firstly, subclass `FKInputItem`, override `viewForItem`.
```
@interface FKSampleTextAreaItem : FKInputItem
```

In the implementation, override `viewForItem` to return an instance of the view class for this input control.
```
-(FKFormItemView *)viewForItem {
    return [FKSampleTextAreaView new];
}
```

Secondly, subclass `FKInputControlView`.
```
@interface FKSampleTextAreaView : FKInputControlView
```

In the implementation, override `heightForWidth:` and `reload` methods.
```
-(CGFloat)heightForWidth:(CGFloat)width {
    return kTextAreaViewHeight;
}

-(void)reload {
    
    FKSampleTextAreaItem *input = (FKSampleTextAreaItem *)self.item;
    _fieldLabel.text = input.label;
    _textView.text = input.value;
    
    if (input.disabled) {
        _textView.editable = NO;
        _fieldLabel.textColor = [UIColor lightGrayColor];
    } else {
        _textView.editable = YES;
        _fieldLabel.textColor = self.tintColor;
    }
    
    [self setNeedsLayout];
}
```

The full source code for `FKSampleTextAreaItem` and `FKSampleTextAreaView` is included within demos folder of the project.
