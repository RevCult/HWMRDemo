public class FC_RequiredDecoratorController {

    public String forComponentId { get; set; }

    public Component.Apex.OutputPanel getMessageForComponent() {
        Component.Apex.OutputPanel pnlErrorMessage = new Component.Apex.OutputPanel();
        if (String.isNotBlank(forComponentId)) {
            pnlErrorMessage.styleClass = 'errorMsg';
            pnlErrorMessage.layout = 'block';
            Component.Apex.Message message = new Component.Apex.Message();
            message.expressions.for = '{!forId}';
            pnlErrorMessage.childComponents.add(message);
        }
        return pnlErrorMessage;
    }

}