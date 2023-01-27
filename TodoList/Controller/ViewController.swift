//
//  ViewController.swift
//  TodoList
//
//  Created by gonzalo trujillo vallejo on 27/1/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var listaDeTareas = [Tarea]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tablaTareas: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        
        //Cuando la app carga, llama al metodo leerTareas para recuperar los datos
        leerTareas()
        
    }
    
    // Si el botón "nuevaTarea" es pulsado, se crea una alerta
    @IBAction func nuevaTarea(_ sender: UIBarButtonItem) {
        // Variable para almacenar el texto ingresado en el recuadro de la alerta
        var nombreTarea = UITextField()
        
        // Se crea la alerta
        let alerta = UIAlertController(title: "Nueva tarea", message: "Tarea", preferredStyle: .alert)
        
        // Acción para aceptar la creación de la nueva tarea
        let accionAceptar = UIAlertAction(title: "Añadir", style: .default) { accion in
            // Se crea una nueva tarea y se asigna el nombre ingresado en la alerta
            let nuevaTarea = Tarea(context: self.context)
            nuevaTarea.title = nombreTarea.text
            nuevaTarea.done = false
            
            // Se añade la nueva tarea a la lista de tareas
            self.listaDeTareas.append(nuevaTarea)
            
            // Se guardan los cambios
            self.guardar()
        }
        
        // Se añade un campo de texto a la alerta para ingresar el nombre de la tarea
        alerta.addTextField { textFieldAlerta in
            textFieldAlerta.placeholder = "Escribe el nombre de la terea"
            nombreTarea = textFieldAlerta
        }
        
        // Se añade la acción de aceptar a la alerta
        alerta.addAction(accionAceptar)
        
        // Se presenta la alerta en pantalla
        present(alerta, animated: true)
        
    }
    
    
    // Esta función guarda los cambios en el contexto de Core Data
    func guardar(){
        // Se utiliza un do-catch para manejar errores al momento de guardar los cambios
        do{
            // Se intenta guardar los cambios en el contexto
            try context.save()
        }catch{
            // Si ocurre un error al momento de guardar, se imprime el error en consola
            print("Error guardando los cambios \(error)")
        }
        
        // Se actualiza la tabla de tareas para reflejar los cambios
        self.tablaTareas.reloadData()
    }
    
    // Esta función lee las tareas almacenadas en Core Data
    func leerTareas(){
        // Se crea una solicitud para leer entidades de tipo Tarea
        let solicitud : NSFetchRequest<Tarea> =  Tarea.fetchRequest()
        
        // Se utiliza un do-catch para manejar errores al momento de leer los datos
        do {
            // Se intenta leer las tareas mediante la solicitud creada
            listaDeTareas = try context.fetch(solicitud)
        }catch{
            // Si ocurre un error al momento de leer, se imprime el error en consola
            print("Error solicitando los datos \(error.localizedDescription)")
        }
    }
    
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let tarea = listaDeTareas[indexPath.row]
        
        //Operador ternario
        celda.textLabel?.text = tarea.title
        celda.textLabel?.textColor = tarea.done ? .black : .blue
        celda.detailTextLabel?.text = tarea.done ? "Completada" : "Sin completar"
        
        //Marcar con un check si la tarea está completada o no
        celda.accessoryType = tarea.done ? .checkmark : .none
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //Editar en coredata
        listaDeTareas[indexPath.row].done = !listaDeTareas[indexPath.row].done
        
        //Guardamo los cambios
        guardar()
        
        //Deseleccionar tarea
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "Eliminar") { _, _, _ in
            self.context.delete(self.listaDeTareas[indexPath.row])
            self.listaDeTareas.remove(at: indexPath.row)
            
            //Guardamos los cambios en la base de datos
            self.guardar()
        }
        //Color al eliminar elemento
        accionEliminar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
}
