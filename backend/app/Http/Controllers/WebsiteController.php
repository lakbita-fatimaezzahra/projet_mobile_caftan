<?php

namespace App\Http\Controllers;

use App\Models\Caftan;
use App\Models\Category;
use App\Models\Setting;
use Illuminate\Http\Request;

class WebsiteController extends Controller
{
    protected function getSettings(): ?Setting
    {
        return Setting::first();
    }

    public function index()
    {
        $settings = $this->getSettings();
        $categories = Category::orderBy('name')->take(6)->get();
        $caftans = Caftan::with(['primaryImage', 'images', 'category'])
            ->orderByDesc('created_at')
            ->take(10)
            ->get();

        return view('pages.home', compact('settings', 'categories', 'caftans'));
    }

    public function caftans(Request $request)
    {
        $settings = $this->getSettings();
        $categories = Category::orderBy('name')->get();

        $query = Caftan::with(['primaryImage', 'category']);

        if ($search = $request->input('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        if ($categoryId = $request->input('category')) {
            $query->where('category_id', $categoryId);
        }

        if ($request->boolean('available', false)) {
            $query->where('is_available', true);
        }

        if ($minPrice = $request->input('min_price')) {
            $query->where('price_per_day', '>=', $minPrice);
        }

        if ($maxPrice = $request->input('max_price')) {
            $query->where('price_per_day', '<=', $maxPrice);
        }

        $caftans = $query->orderBy('name')->paginate(12)->withQueryString();

        return view('pages.caftans', compact('settings', 'categories', 'caftans'));
    }

    public function caftanDetail($id)
    {
        $settings = $this->getSettings();
        $caftan = Caftan::with(['images', 'category'])->findOrFail($id);

        return view('pages.caftan-detail', compact('settings', 'caftan'));
    }

    public function about()
    {
        $settings = $this->getSettings();

        return view('pages.about', compact('settings'));
    }

    public function contact()
    {
        $settings = $this->getSettings();

        return view('pages.contact', compact('settings'));
    }
}
