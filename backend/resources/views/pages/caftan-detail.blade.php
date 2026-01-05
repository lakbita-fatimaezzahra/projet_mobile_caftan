@extends('layouts.app')

@section('content')
    <div class="max-w-5xl mx-auto px-4 py-8 grid md:grid-cols-2 gap-8">
        <div>
            <div class="aspect-[3/4] bg-gray-200 rounded overflow-hidden mb-3">
                @if($caftan->images->count())
                    <img
                        id="caftan-main-image"
                        src="{{ asset('storage/'.$caftan->images->first()->image_path) }}"
                        alt="{{ $caftan->name }}"
                        class="w-full h-full object-cover">
                @endif
            </div>
            @if($caftan->images->count())
                <div class="flex gap-2 overflow-x-auto">
                    @foreach($caftan->images as $index => $image)
                        <button
                            type="button"
                            class="w-20 h-24 rounded overflow-hidden border focus:outline-none {{ $loop->first ? 'ring-2 ring-emerald-500' : '' }}"
                            data-caftan-thumb
                            data-src="{{ asset('storage/'.$image->image_path) }}">
                            <img src="{{ asset('storage/'.$image->image_path) }}" alt="{{ $caftan->name }}" class="w-full h-full object-cover">
                        </button>
                    @endforeach
                </div>
            @endif
        </div>

        <div>
            <h1 class="text-2xl font-bold mb-2">{{ $caftan->name }}</h1>
            <p class="text-gray-600 mb-2">{{ $caftan->category->name ?? '' }}</p>
            <p class="text-lg font-semibold mb-2">{{ $caftan->price_per_day }} MAD / jour</p>
            <p class="mb-4">{{ $caftan->category->description }}</p>

            <div class="border-t pt-4 mt-4">
                <h3 class="font-semibold mb-2">Contact pour réservation</h3>
                <p class="text-sm mb-1">Téléphone : {{ $settings->phone ?? '-' }}</p>
                <p class="text-sm mb-1">WhatsApp : {{ $settings->whatsapp ?? $settings->phone ?? '-' }}</p>
                <p class="text-sm mb-3">Email : {{ $settings->email ?? '-' }}</p>
                </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const mainImage = document.getElementById('caftan-main-image');
            if (!mainImage) return;

            const thumbs = document.querySelectorAll('[data-caftan-thumb]');
            thumbs.forEach((thumb) => {
                thumb.addEventListener('click', () => {
                    const src = thumb.getAttribute('data-src');
                    if (src) {
                        mainImage.src = src;
                    }

                    thumbs.forEach((t) => {
                        t.classList.remove('ring-2', 'ring-emerald-500');
                    });
                    thumb.classList.add('ring-2', 'ring-emerald-500');
                });
            });
        });
    </script>
@endsection
