<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Caftan;
use App\Models\CaftanImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminCaftanController extends Controller
{
    public function index(Request $request)
    {
        // Charger la catégorie + l'image principale + toutes les images
        $query = Caftan::with(['category', 'primaryImage', 'images']);

        if ($search = $request->input('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        // Accepter à la fois ?category= et ?category_id= pour plus de souplesse côté front
        $categoryId = $request->input('category') ?? $request->input('category_id');
        if ($categoryId) {
            $query->where('category_id', $categoryId);
        }

        if ($availability = $request->input('availability')) {
            if ($availability === 'available') {
                $query->where('is_available', true);
            } elseif ($availability === 'rented') {
                $query->where('is_available', false);
            }
        }

        $caftans = $query->paginate(15);

        return response()->json($caftans);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'price_per_day' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'is_available' => 'boolean',
        ]);

        $caftan = Caftan::create($data);

        return response()->json($caftan, 201);
    }

    public function show($id)
    {
        // Les relations colors / sizes ont été supprimées du modèle
        $caftan = Caftan::with(['category', 'images', 'primaryImage'])->findOrFail($id);

        return response()->json($caftan);
    }

    public function update(Request $request, $id)
    {
        $caftan = Caftan::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'price_per_day' => 'sometimes|required|numeric|min:0',
            'category_id' => 'sometimes|required|exists:categories,id',
            'is_available' => 'boolean',
        ]);

        $caftan->update($data);

        return response()->json($caftan);
    }

    public function destroy($id)
    {
        $caftan = Caftan::findOrFail($id);
        $caftan->delete();

        return response()->json(['message' => 'Caftan supprimé avec succès']);
    }

    public function updateAvailability(Request $request, $id)
    {
        $caftan = Caftan::findOrFail($id);

        $data = $request->validate([
            'is_available' => 'required|boolean',
        ]);

        $caftan->update($data);

        return response()->json($caftan);
    }

    public function uploadImages(Request $request, $id)
    {
        $caftan = Caftan::findOrFail($id);

        $request->validate([
            'images.*' => 'required|image|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        $uploaded = [];

        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('caftans', 'public');

                $caftanImage = CaftanImage::create([
                    'caftan_id' => $caftan->id,
                    'image_path' => $path,
                    'is_primary' => $request->boolean('is_primary') && $index === 0,
                    'order' => $request->input('order', $index),
                ]);

                $uploaded[] = $caftanImage;
            }
        }

        return response()->json($uploaded, 201);
    }
}
