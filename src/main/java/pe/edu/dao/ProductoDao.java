
package pe.edu.dao;

import java.util.LinkedList;
import pe.edu.entity.Producto;

public class ProductoDao implements DaoCrud<Producto>{ 

    @Override
    public LinkedList<Producto> listar() {
        return null;
    }

    @Override
    public void insertar(Producto obj) {        
    }

    @Override
    public Producto leer(String id) {
        return null;
    }

    @Override
    public void editar(Producto obj) {        
    }

    @Override
    public void eliminar(String id) {        
    }
    
}
