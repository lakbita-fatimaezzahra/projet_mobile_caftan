@extends('layouts.app')

@section('content')
<div class="bg-gradient-to-b from-pink-50 via-white to-rose-50 py-16">
    <div class="max-w-6xl mx-auto px-6 grid md:grid-cols-2 gap-12 items-center">

        {{-- Image --}}
        <div class="relative">
            <img src="{{ asset('images/caftan.jpg') }}"
                 alt="Caftans marocains"
                 class="rounded-3xl shadow-2xl object-cover w-full h-[420px]">
            <div class="absolute -bottom-6 -left-6 bg-rose-600 text-white px-6 py-3 rounded-xl shadow-lg text-sm font-semibold">
                Élégance Marocaine
            </div>
        </div>

        {{-- Texte --}}
        <div>
            <h1 class="text-4xl font-extrabold text-gray-800 mb-6">
                À propos de <span class="text-rose-600">nous</span>
            </h1>

            <p class="text-gray-700 leading-relaxed mb-4">
                {!! nl2br(e($settings->description ?? 
                'Nous sommes spécialisés dans la location de caftans marocains traditionnels et modernes, soigneusement sélectionnés pour sublimer toutes vos occasions spéciales.')) !!}
            </p>

            <p class="text-gray-700 leading-relaxed mb-4">
                Mariage, fiançailles, fêtes, soirées ou cérémonies, notre collection reflète
                l’alliance parfaite entre <strong>raffinement</strong>, <strong>authenticité</strong>
                et <strong>tendance</strong>.
            </p>

            <p class="text-gray-700 leading-relaxed mb-6">
                Chaque caftan est choisi avec attention pour garantir une qualité irréprochable,
                des finitions luxueuses et un confort exceptionnel, afin que chaque cliente
                se sente <strong>unique</strong> et <strong>sublime</strong>.
            </p>

            <div class="flex items-center gap-4">
                <span class="inline-block bg-rose-100 text-rose-700 px-5 py-2 rounded-full text-sm font-medium">
                    ✨ Élégance
                </span>
                <span class="inline-block bg-pink-100 text-pink-700 px-5 py-2 rounded-full text-sm font-medium">
                    👗 Luxe
                </span>
                <span class="inline-block bg-fuchsia-100 text-fuchsia-700 px-5 py-2 rounded-full text-sm font-medium">
                    🇲🇦 Tradition
                </span>
            </div>
        </div>

    </div>
</div>
@endsection
