import "java.awt.BorderLayout"
import "java.awt.Dimension"
import "java.util.Vector"
import "javax.swing.JFrame"
import "javax.swing.JList"
import "javax.swing.JPanel"
import "javax.swing.JScrollPane"
import "javax.swing.JSplitPane"
import "javax.swing.JTextArea"

require 'lib/pophealth_importer_menu_bar'
require 'lib/pophealth_importer_listener'
require 'lib/pophealth_importer_control_panel'

class PophealthImporterJframe < JFrame

  @@initial_window_dimension = Dimension.new(700, 500)

  def initialize (pophealth_listener)

    super("popHealth Continuity of Care XML Importer")

    # setup children UI components
    @pophealth_importer_menu_bar = PophealthImporterMenuBar.new()
    @pophealth_importer_menu_bar.add_pophealth_importer_listener(pophealth_listener)

    # pull it all together...
    setJMenuBar(@pophealth_importer_menu_bar)
    @content_pane = JPanel.new()
    @content_pane.setLayout(BorderLayout.new())
    @file_list = JList.new()

    @control_panel = PophealthImporterControlPanel.new()
    @control_panel.add_pophealth_importer_listener(pophealth_listener)
    @content_pane.add(@control_panel, BorderLayout::NORTH)

    @file_list = JList.new(Vector.new())
    @text_area = JTextArea.new()
    @file_scroll_pane = JScrollPane.new(@file_list)
    @split_pane = JSplitPane.new(JSplitPane::HORIZONTAL_SPLIT,
                                 @file_scroll_pane,
                                 @text_area)
    @split_pane.setDividerLocation(200)
    @content_pane.add(@split_pane, BorderLayout::CENTER)

    getContentPane().add(@content_pane)
    setSize(@@initial_window_dimension)
  end

  def get_control_panel
    @control_panel
  end

  def set_play_mode(play_mode)
    @pophealth_importer_menu_bar.set_play_mode(play_mode)
    @control_panel.set_play_mode(play_mode)
  end

  def enable_play
    @pophealth_importer_menu_bar.enable_play
    @control_panel.enable_play
  end

  def set_patient_directory(patient_directory)
    @patient_directory = patient_directory
    @patient_files = patient_directory.listFiles() 
    patients_files_vector = Vector.new()
    number_patient_files = @patient_files.length
    counter = 0
    while counter < number_patient_files
      patients_files_vector.add(@patient_files[counter].getName())
      counter += 1
    end
    @file_list.setListData(patients_files_vector)
  end

end