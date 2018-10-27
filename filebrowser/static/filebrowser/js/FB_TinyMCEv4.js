/**
 * Created by Sune Kjærgård on 04/02/2016.
 * Originaly authored by Alan Hicks
 * http://p-o.co.uk/tech-articles/howto-use-tinymce-with-django-filebrowser-media-manager/
 */
var FileBrowserDialogue = {
    fileSubmit : function (FileURL) {
        parentWin = (!window.frameElement && window.dialogArguments) || parent;
        tinymce = tinyMCE = parentWin.tinymce;
        self.editor = tinymce.EditorManager.activeEditor;
        self.params = self.editor.windowManager.getParams();
        input_control = parentWin.document.getElementById(self.params.input);
        if (input_control != null) {
            input_control.value = FileURL;
        }
        self.editor.windowManager.close(parentWin);
    },
}
